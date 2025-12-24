---
paths: test/infrastructure/**/*_test.rb
dependencies: []
---

# Infrastructure Testing

This directory contains tests for database-level infrastructure that isn't part of the application code but affects application behavior.

## What belongs here

- Database trigger tests (SQLite triggers that maintain data)
- Virtual table maintenance tests
- Database-level constraint tests
- Other infrastructure that operates at the database level

## What doesn't belong here

- Model behavior tests (go in test/models/)
- Service/command tests (go in test/services/ or test/business_logic/)
- Controller tests (go in test/controllers/)
- Application code tests of any kind

## Note

These tests are intentionally separate from model tests because they test database infrastructure behavior, not application model behavior. This maintains proper separation of concerns even though the infrastructure affects model data.
