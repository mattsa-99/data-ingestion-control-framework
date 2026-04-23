import os
import yaml
import psycopg2
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

def load_settings(base_path):
    """
    Reads the configuration from the YAML file located in the config folder.
    """
    config_path = base_path / 'config' / 'settings.yaml'
    if not config_path.exists():
        raise FileNotFoundError(f"Config file not found at: {config_path}")
    with open(config_path, 'r') as f:
        return yaml.safe_load(f)

def render_sql(sql_template, database_config):
    """
    Replaces {{placeholder}} tags in SQL files with values defined in settings.yaml.
    """
    rendered_sql = sql_template
    for key, value in database_config.items():
        placeholder = f"{{{{{key}}}}}"
        rendered_sql = rendered_sql.replace(placeholder, str(value))
    return rendered_sql

def deploy():
    """
    Orchestrates the deployment of the database schema, tables, and logic.
    """
    # PATH ADJUSTMENT:
    # deploy.py is located in src/python/. 
    # We move up 2 levels to reach the project root.
    BASE_PATH = Path(__file__).resolve().parent.parent.parent
    
    # SQL files are located in src/sql/
    SQL_ROOT = BASE_PATH / 'src' / 'sql'
    
    print(f"Project Root: {BASE_PATH}")
    print(f"SQL Files Source: {SQL_ROOT}\n")

    try:
        # Load configurations
        settings = load_settings(BASE_PATH)
        db_config = settings['database']
        conn_config = settings['connection']

        # Establish connection to PostgreSQL
        conn = psycopg2.connect(
            host=conn_config['host'],
            port=conn_config['port'],
            database=conn_config['database'],
            user=conn_config['user'],
            password=os.getenv('DB_PASSWORD')
        )
        cursor = conn.cursor()
        print("Successfully connected to PostgreSQL.")

        # UPDATED LIST BASED ON YOUR DIRECTORY STRUCTURE
        # Order matters: Setup -> Tables -> Functions -> Stored Procedures
        sql_order = [
            'setup/00_setup_schema.sql',
            'tables/01_ingestion_control_table.sql',
            'tables/02_audit_log_table.sql',
            'functions/03_fn_get_dynamic_path.sql',
            'stored-procedures/04_get_ingestion_control.sql',
            'stored-procedures/05_save_audit_log.sql'
        ]

        for sql_file in sql_order:
            # Look for the file inside src/sql/
            file_path = SQL_ROOT / sql_file
            print(f"Deploying: {sql_file}...", end=" ")
            
            if not file_path.exists():
                print(f"FAILED (Not found at {file_path})")
                continue

            # Read SQL Template
            with open(file_path, 'r') as f:
                template = f.read()

            # Replace placeholders with YAML values
            final_sql = render_sql(template, db_config)
            
            # Execute and commit
            cursor.execute(final_sql)
            conn.commit()
            print("SUCCESS")

        print("\n✅ All set! Your framework database is ready.")

    except Exception as e:
        print(f"\n❌ Error: {e}")
        if 'conn' in locals(): 
            conn.rollback()
    finally:
        # Close resources
        if 'cursor' in locals(): 
            cursor.close()
        if 'conn' in locals(): 
            conn.close()

if __name__ == "__main__":
    deploy()