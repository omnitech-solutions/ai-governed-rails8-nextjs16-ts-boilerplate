---
name: service
aliases: [extract-service, service-object]
description: Extract complex logic into an orchestrator action or a standalone service object.
targets: [claude, cursor, codex]
---
# /service – Extract Service Logic

Extract the logic in **{{ARGUMENTS}}** into the service layer.

## For CRUD Operations
Use the orchestrator pattern. Override or add action methods in the existing resource orchestrator:

```ruby
# app/services/company_orchestrator.rb
class CompanyOrchestrator < ApplicationOrchestrator
  crud_actions

  private

  def validate(context)
    # custom validation logic
    super
  end
end
```

## For Standalone Complex Workflows
Create a PORO service object with a `Result` pattern:

```ruby
# app/services/archive_project.rb
class ArchiveProject
  def self.call(project)
    new(project).call
  end

  def initialize(project)
    @project = project
  end

  def call
    return Result.failure("Not archivable") unless archivable?
    @project.update!(archived_at: Time.current)
    Result.success(data: @project)
  rescue ActiveRecord::RecordInvalid => e
    Result.failure(e.message)
  end

  class Result
    def self.success(data: nil) = new(success: true, data: data)
    def self.failure(error) = new(success: false, error: error)
    attr_reader :success, :data, :error
    def initialize(success:, data: nil, error: nil)
      @success = success
      @data = data
      @error = error
    end
    def success? = success
  end

  private

  def archivable?
    @project.tasks.all?(&:completed?)
  end
end
```

## Controller Usage (if not using Serviceable)

```ruby
result = ArchiveProject.call(@project)
if result.success?
  render json: { data: result.data }, status: :ok
else
  render json: { errors: [{ detail: result.error }] }, status: :unprocessable_entity
end
```

Write corresponding specs in `spec/services/`.
