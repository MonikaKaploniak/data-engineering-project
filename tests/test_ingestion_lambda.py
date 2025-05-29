from src.ingestion_lambda_handler import lambda_handler
from unittest.mock import patch, MagicMock

def test_lambda_handler_success():
    event = {}
    context = {}

    with patch("src.ingestion_lambda_handler.pg8000.native.Connection") as mock_connect:
        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        mock_connect.return_value = mock_conn
        mock_conn.cursor.return_value = mock_cursor
        
        mock_cursor.fetchall.return_value = [
            ("row1_col1", "row1_col2"),
            ("row2_col1", "row2_col2"),
        ]
        
        with patch("src.ingestion_lambda_handler.s3_client") as mock_s3:
            mock_s3.put_object = MagicMock(return_value={"ResponseMetadata": {"HTTPStatusCode": 200}})

            response = lambda_handler(event, context)

            assert response['statusCode'] == 200
            assert response['body'] == 'Uploaded 11 tables to S3 totesys-ingestion-bucket'
