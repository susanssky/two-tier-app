DROP TABLE IF EXISTS ec2_status;

CREATE TABLE ec2_status (
  instance_id VARCHAR(50) PRIMARY KEY,
  ec2_name VARCHAR(50) NOT NULL,
  cpu TEXT,
  is_bookmarked BOOLEAN DEFAULT false
);