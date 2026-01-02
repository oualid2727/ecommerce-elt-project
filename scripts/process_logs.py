import re
import pandas as pd
from datetime import datetime
import snowflake.connector
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv('config/.env')

def parse_payment_logs(log_file_path):
    """
    Parse payment log files into structured data
    
    Args:
        log_file_path: Path to the log file
    
    Returns:
        DataFrame with parsed log data
    """
    pattern = r'\[(.*?)\] CommandeID: (\d+) \| ClientID: (\d+) \| Statut Paiement: (.*?)$'
    
    records = []
    with open(log_file_path, 'r', encoding='utf-8') as f:
        for line_num, line in enumerate(f, 1):
            match = re.match(pattern, line.strip())
            if match:
                try:
                    records.append({
                        'timestamp': match.group(1),
                        'commande_id': int(match.group(2)),
                        'client_id': int(match.group(3)),
                        'statut_paiement': match.group(4).strip()
                    })
                except ValueError as e:
                    print(f"Warning: Could not parse line {line_num}: {e}")
            else:
                print(f"Warning: Line {line_num} doesn't match pattern: {line.strip()}")
    
    df = pd.DataFrame(records)
    print(f"Successfully parsed {len(df)} payment records")
    return df

def upload_to_snowflake(df, table_name):
    """
    Upload DataFrame to Snowflake
    
    Args:
        df: DataFrame to upload
        table_name: Target table name
    """
    try:
        # Connect to Snowflake
        conn = snowflake.connector.connect(
            user=os.getenv('AIRBYTE_SNOWFLAKE_USER'),
            password=os.getenv('AIRBYTE_SNOWFLAKE_PASSWORD'),
            account=os.getenv('SNOWFLAKE_ACCOUNT'),
            warehouse=os.getenv('SNOWFLAKE_WAREHOUSE'),
            database=os.getenv('SNOWFLAKE_DATABASE'),
            schema='RAW_DATA'
        )
        
        cursor = conn.cursor()
        
        # Create table if not exists
        create_table_sql = f"""
        CREATE TABLE IF NOT EXISTS {table_name} (
            timestamp TIMESTAMP_NTZ,
            commande_id INTEGER,
            client_id INTEGER,
            statut_paiement VARCHAR(50),
            loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
        )
        """
        cursor.execute(create_table_sql)
        print(f"Table {table_name} created or already exists")
        
        # Truncate table (for full reload)
        cursor.execute(f"TRUNCATE TABLE IF EXISTS {table_name}")
        print(f"Table {table_name} truncated")
        
        # Insert data
        insert_count = 0
        for _, row in df.iterrows():
            insert_sql = f"""
            INSERT INTO {table_name} 
            (timestamp, commande_id, client_id, statut_paiement)
            VALUES (
                TO_TIMESTAMP_NTZ('{row['timestamp']}', 'YYYY-MM-DD HH24:MI:SS'),
                {row['commande_id']},
                {row['client_id']},
                '{row['statut_paiement']}'
            )
            """
            cursor.execute(insert_sql)
            insert_count += 1
        
        conn.commit()
        print(f"✅ Successfully uploaded {insert_count} records to {table_name}")
        
        # Verify upload
        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
        count = cursor.fetchone()[0]
        print(f"Table {table_name} now contains {count} rows")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Error uploading to Snowflake: {str(e)}")
        raise

def main():
    """Main execution function"""
    print("=" * 60)
    print("Payment Log Processing Script")
    print("=" * 60)
    
    # Parse logs
    print("\n1. Parsing payment logs...")
    df_payments = parse_payment_logs('data/logs/paiements.log')
    
    # Display sample
    print("\nSample data:")
    print(df_payments.head())
    
    # Upload to Snowflake
    print("\n2. Uploading to Snowflake...")
    upload_to_snowflake(df_payments, 'RAW_PAIEMENTS')
    
    print("\n" + "=" * 60)
    print("Process completed successfully!")
    print("=" * 60)

if __name__ == "__main__":
    main()