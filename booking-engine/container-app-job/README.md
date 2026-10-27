# Container Apps migration job

Creates a manually triggered Container Apps Job in an existing Container Apps
environment. The job can use the API image with a command override to run
database migrations. Applying Terraform creates the job; it does not start an
execution.

The PostgreSQL password and ACR password are configured as Container Apps
secrets, and environment variables can reference those secrets by name. These
values are still supplied to Terraform and can be present in Terraform state;
restrict access to the state backend.

The job must use an environment connected to the VNet that contains the
PostgreSQL private endpoint. Its caller is responsible for ordering the job
execution after the database exists and before relying on the API schema.