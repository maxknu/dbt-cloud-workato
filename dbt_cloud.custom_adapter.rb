{
  title: "dbt Cloud",

  connection: {
    fields: [
      {
        name: 'api_version',
        control_type: 'select',
        pick_list: [
          ['v2', 'v2'],
          ['v3', 'v3']
        ],
        optional: false
      },
      {
        name: 'datacenter',
        control_type: 'select',
        pick_list: [
          ['Production (US)', 'cloud'],
          ['Production (Europe)', 'emea'],
          ['Production (AU)', 'au']
        ],
        optional: false
      },
      {
        name: 'api_key',
        control_type: 'password',
        hint: 'Find your API key in your dbt Cloud account settings. Retrieve from Account Settings > Service Tokens > Create Service Token',
        optional: false
      },
      {
        name: "account_id", optional: false
      }
    ],
    authorization: {
      type: 'api_key',
      apply: lambda do |connection|
        headers('Authorization': "Token #{connection['api_key']}")
      end
    },
    base_uri: lambda do |connection|
      "https://#{connection['datacenter']}.getdbt.com"
    end
  },
  test: lambda do |connection|
    get("/api/#{connection['api_version']}/accounts/")
  end,

  custom_action: true,

  custom_action_help: {
    learn_more_url: 'https://docs.getdbt.com/docs/dbt-cloud-apis/overview',
    learn_more_text: 'dbt Cloud API documentation',
    body: 'Build your own dbt action with a HTTP request. The request will be authorized with your current connection. More documentation under postman docs https://documenter.getpostman.com/view/14183654/UVsSNiXC#intro'
  },

  actions: {
    list_jobs: {
      title: "List Jobs",
      subtitle: "List all jobs in an account",
      description: lambda do |_input, _picklist_label|
        "List <span class='provider'>Jobs</span> in <span class='provider'>dbt Cloud</span>"
      end,
      help: lambda do |_input, _picklist_label|
        "This action lists all jobs in a specified dbt Cloud account."
      end,
      input_fields: lambda do |_object_definitions, _connection, _config_fields|
        [
          { name: "order_by", hint: "Field to order the result by. Use - to indicate reverse order.", 
            type: "string", control_type: "text", optional: true, sticky: true },
          { name: "project_id", hint: "Numeric ID of the project containing jobs", 
            type: "integer", control_type: "number", optional: true, sticky: true }
        ]
      end,
      execute: lambda do |connection|
        get("api/#{connection['api_version']}/accounts/#{connection['account_id']}/jobs/").
          after_error_response(/.*/) do |_code, body, _header, message|
            error("#{message}: #{body}")
          end
      end,
      output_fields: lambda do |_object_definitions, _connection, _config_fields|
        [
          { name: "data", type: "array", of: "object", properties: [
            { name: "id", type: "integer" },
            { name: "account_id", type: "integer" },
            { name: "project_id", type: "integer" },
            { name: "environment_id", type: "integer" },
            { name: "name", type: "string" },
            { name: "dbt_version", type: "string" },
            { name: "triggers", type: "object", properties: [
              { name: "github_webhook", type: "boolean" },
              { name: "git_provider_webhook", type: "boolean" },
              { name: "schedule", type: "boolean" },
              { name: "custom_branch_only", type: "boolean" }
            ] },
            { name: "execute_steps", type: "array", of: "string" },
            { name: "settings", type: "object", properties: [
              { name: "threads", type: "integer" },
              { name: "target_name", type: "string" }
            ] },
            { name: "state", type: "integer" },
            { name: "generate_docs", type: "boolean" },
            { name: "schedule", type: "object", properties: [
              { name: "cron", type: "string" },
              { name: "date", type: "object", properties: [
                { name: "type", type: "string" },
                { name: "days", type: "array", of: "integer" },
                { name: "cron", type: "string" }
              ] },
              { name: "time", type: "object", properties: [
                { name: "type", type: "string" },
                { name: "interval", type: "integer" },
                { name: "hours", type: "array", of: "integer" }
              ] }
            ] }
          ] },
          { name: "status", type: "object", properties: [
            { name: "code", type: "integer" },
            { name: "is_success", type: "boolean" },
            { name: "user_message", type: "string" },
            { name: "developer_message", type: "string" }
          ] }
        ]
      end
    },

    list_job_by_id: {
      title: "Retrieve Job",
      subtitle: "List a specific job in dbt",
      description: lambda do |_input, _picklist_label|
        "List <span class='provider'>Job</span> in <span class='provider'>dbt</span>"
      end,
      help: lambda do |_input, _picklist_label|
        "This action allows you to retrieve a specific job in dbt. You need to provide the account ID and job ID."
      end,
      input_fields: lambda do |_object_definitions, _connection, _config_fields|
        [
          { name: 'id', hint: 'Job ID', type: 'integer', control_type: 'number', optional: false },
          { name: 'account__locked', hint: 'Account locked status', type: 'boolean', control_type: 'checkbox', optional: true, sticky: false },
          { name: 'account__state', hint: 'Account state', type: 'integer', control_type: 'number', optional: true, sticky: false },
          { name: 'deactivated', hint: 'Deactivated status', type: 'boolean', control_type: 'checkbox', optional: true, sticky: false },
          { name: 'environment__state', hint: 'Environment state', type: 'integer', control_type: 'number', optional: true, sticky: false },
          { name: 'environment_id', hint: 'Environment ID', type: 'integer', control_type: 'number', optional: true, sticky: false },
          { name: 'id__gt', hint: 'Job ID greater than', type: 'integer', control_type: 'number', optional: true, sticky: false },
          { name: 'limit', hint: 'Limit', type: 'integer', control_type: 'number', optional: true, sticky: false },
          { name: 'name__icontains', hint: 'Job name contains', type: 'string', control_type: 'text', optional: true, sticky: false },
          { name: 'offset', hint: 'Offset', type: 'integer', control_type: 'number', optional: true, sticky: false },
          { name: 'project__state', hint: 'Project state', type: 'integer', control_type: 'number', optional: true, sticky: false },
          { name: 'project_id', hint: 'Project ID', type: 'integer', control_type: 'number', optional: true, sticky: false },
          { name: 'state', hint: 'State', type: 'integer', control_type: 'number', optional: true, sticky: false },
          { name: 'triggers_schedule', hint: 'Triggers schedule', type: 'boolean', control_type: 'checkbox', optional: true}
        ]
      end,
      execute: lambda do |_connection, input, _extended_input_schema, _extended_output_schema, _continue|
        get("api/v2/accounts/#{_connection['account_id']}/jobs/#{input['id']}/")
      end,
      output_fields: lambda do |_object_definitions, _connection, _config_fields|
        [
          { name: 'account_id', type: 'integer' },
          { name: 'id', type: 'integer' },
          { name: 'account__locked', type: 'boolean' },
          { name: 'account__state', type: 'integer' },
          { name: 'deactivated', type: 'boolean' },
          { name: 'environment__state', type: 'integer' },
          { name: 'environment_id', type: 'integer' },
          { name: 'id__gt', type: 'integer' },
          { name: 'limit', type: 'integer' },
          { name: 'name__icontains', type: 'string' },
          { name: 'offset', type: 'integer' },
          { name: 'project__state', type: 'integer' },
          { name: 'project_id', type: 'integer' },
          { name: 'state', type: 'integer' },
          { name: 'triggers_schedule', type: 'boolean' }
        ]
      end
    },

    list_accounts: {
      title: "List Accounts",
      subtitle: "List all accounts in DBT",
      description: lambda do |input, picklist_label|
        "List <span class='provider'>Accounts</span> in <span class='provider'>DBT</span>"
      end,
      help: lambda do |input, picklist_label|
        "This action will retrieve all accounts from DBT."
      end,
      input_fields: lambda do |object_definitions, connection, config_fields|
        []
      end,
      execute: lambda do |connection, input, extended_input_schema, extended_output_schema, continue|
        get("api/#{connection['api_version']}/accounts/").
          after_error_response(/.*/) do |code, body, header, message|
            error("#{message}: #{body}")
          end
      end,
      output_fields: lambda do |object_definitions, connection, config_fields|
        [
          { name: "data", type: "array", of: "object", properties: [
            { name: "id", type: "integer" },
            { name: "name", type: "string" },
            { name: "plan", type: "string" },
            { name: "pending_cancel", type: "boolean" },
            { name: "state", type: "integer" },
            { name: "developer_seats", type: "integer" },
            { name: "read_only_seats", type: "integer" },
            { name: "run_slots", type: "integer" },
            { name: "created_at", type: "timestamp" },
            { name: "updated_at", type: "timestamp" }
          ]},
          { name: "status", type: "object", properties: [
            { name: "code", type: "integer" },
            { name: "is_success", type: "boolean" },
            { name: "user_message", type: "string" },
            { name: "developer_message", type: "string" }
          ]}
        ]
      end
    },

    list_runs: {
      title: "List Runs",
      subtitle: "List all runs in an account",
      description: lambda do |_input, _picklist_label|
        "List <span class='provider'>Runs</span> in <span class='provider'>dbt Cloud</span>"
      end,
      help: lambda do |_input, _picklist_label|
        "This action retrieves a list of runs in a specified dbt Cloud account."
      end,
      input_fields: lambda do |_object_definitions, _connection, _config_fields|
        [
          { name: "include_related", hint: 'List of related fields to pull with the run. Valid values are "trigger", "job", and "debug_logs".', type: "string", control_type: "text", sticky: false },
          { name: "job_definition_id", hint: "Applies a filter to only return runs from the specified Job.", type: "integer", control_type: "number", sticky: false },
          { name: "project_id", hint: "Applies a filter to only return runs from the specified Project.", type: "integer", control_type: "number", sticky: false },
          { name: "status", hint: "Applies a filter to return only runs with the specified Status.", type: "integer", control_type: "number", sticky: false },
          { name: "order_by", hint: 'Field to order the result by. Use - to indicate reverse order.', type: "string", control_type: "text", sticky: false },
          { name: "offset", hint: "The offset to apply when listing runs. Use with limit to paginate results.", type: "integer", control_type: "number", sticky: false },
          { name: "limit", hint: "The limit to apply when listing runs. Use with offset to paginate results.", type: "integer", control_type: "number", sticky: false }
        ]
      end,
      execute: lambda do |_connection, input, _extended_input_schema, _extended_output_schema, _continue|
        get("api/v2/accounts/#{_connection['account_id']}/runs/")
        .after_error_response(/.*/) do |_code, body, _header, message|
          error("#{message}: #{body}")
        end
      end,
      output_fields: lambda do |_object_definitions, _connection, _config_fields|
        [
          { name: "data", type: "array", of: "object", properties: [
            { name: "id", type: "integer" },
            { name: "trigger_id", type: "integer" },
            { name: "account_id", type: "integer" },
            { name: "project_id", type: "integer" },
            { name: "job_definition_id", type: "integer" },
            { name: "status", type: "integer" },
            { name: "git_branch", type: "string" },
            { name: "git_sha", type: "string" },
            { name: "status_message", type: "string" },
            { name: "dbt_version", type: "string" },
            { name: "created_at", type: "timestamp" },
            { name: "updated_at", type: "timestamp" },
            { name: "dequeued_at", type: "timestamp" },
            { name: "started_at", type: "timestamp" },
            { name: "finished_at", type: "timestamp" },
            { name: "last_checked_at", type: "timestamp" },
            { name: "last_heartbeat_at", type: "timestamp" },
            { name: "owner_thread_id", type: "string" },
            { name: "executed_by_thread_id", type: "string" },
            { name: "artifacts_saved", type: "boolean" },
            { name: "artifact_s3_path", type: "string" },
            { name: "has_docs_generated", type: "boolean" },
            { name: "trigger", type: "object", properties: [
              { name: "id", type: "integer" },
              { name: "cause", type: "string" },
              { name: "job_definition_id", type: "integer" },
              { name: "git_branch", type: "string" },
              { name: "git_sha", type: "string" },
              { name: "github_pull_request_id", type: "integer" },
              { name: "schema_override", type: "string" },
              { name: "dbt_version_override", type: "string" },
              { name: "threads_override", type: "integer" },
              { name: "target_name_override", type: "string" },
              { name: "generate_docs_override", type: "boolean" },
              { name: "timeout_seconds_override", type: "integer" },
              { name: "steps_override", type: "array", of: "string" },
              { name: "created_at", type: "timestamp" }
            ] },
            { name: "job", type: "object", properties: [
              { name: "id", type: "integer" },
              { name: "account_id", type: "integer" },
              { name: "project_id", type: "integer" },
              { name: "environment_id", type: "integer" },
              { name: "name", type: "string" },
              { name: "dbt_version", type: "string" },
              { name: "triggers", type: "object", properties: [
                { name: "github_webhook", type: "boolean" },
                { name: "git_provider_webhook", type: "boolean" },
                { name: "schedule", type: "boolean" },
                { name: "custom_branch_only", type: "boolean" }
              ] },
              { name: "execute_steps", type: "array", of: "string" },
              { name: "settings", type: "object", properties: [
                { name: "threads", type: "integer" },
                { name: "target_name", type: "string" }
              ] },
              { name: "state", type: "integer" },
              { name: "generate_docs", type: "boolean" },
              { name: "schedule", type: "object", properties: [
                { name: "cron", type: "string" },
                { name: "date", type: "object", properties: [
                  { name: "type", type: "string" },
                  { name: "days", type: "array", of: "integer" },
                  { name: "cron", type: "string" }
                ] },
                { name: "time", type: "object", properties: [
                  { name: "type", type: "string" },
                  { name: "interval", type: "integer" },
                  { name: "hours", type: "array", of: "integer" }
                ] }
              ] }
            ] },
            { name: "duration", type: "string" },
            { name: "queued_duration", type: "string" },
            { name: "run_duration", type: "string" },
            { name: "duration_humanized", type: "string" },
            { name: "queued_duration_humanized", type: "string" },
            { name: "run_duration_humanized", type: "string" },
            { name: "finished_at_humanized", type: "string" },
            { name: "status_humanized", type: "string" },
            { name: "created_at_humanized", type: "string" }
          ] },
          { name: "status", type: "object", properties: [
            { name: "code", type: "integer" },
            { name: "is_success", type: "boolean" },
            { name: "user_message", type: "string" },
            { name: "developer_message", type: "string" }
          ] }
        ]
      end
    },

    trigger_job_run: {
      title: "Trigger job run",
      subtitle: "Trigger a job run in DBT Cloud",
      description: lambda do |_input, _picklist_label|
        "Trigger a <span class='provider'>job run</span> in <span class='provider'>DBT Cloud</span>"
      end,
      help: lambda do |_input, _picklist_label|
        "This action triggers a job run in DBT Cloud. Provide the required input fields and kick off a job run."
      end,
      input_fields: lambda do |_object_definitions, _connection, _config_fields|
        [
          { name: "job_id", hint: "Job ID", type: "integer", control_type: "number", optional: false },
          { name: "cause", hint: "Cause for triggering the job", type: "string", control_type: "text", optional: false, sticky: true },
          { name: "git_sha", hint: "Git SHA", type: "string", control_type: "text"},
          { name: "git_branch", hint: "Git branch", type: "string", control_type: "text"},
          { name: "azure_pull_request_id", hint: "Azure pull request ID", type: "integer", control_type: "number"},
          { name: "github_pull_request_id", hint: "Github pull request ID", type: "integer", control_type: "number"},
          { name: "gitlab_merge_request_id", hint: "Gitlab merge request ID", type: "integer", control_type: "number"},
          { name: "non_native_pull_request_id", hint: "Non-native pull request ID", type: "integer", control_type: "number"},
          { name: "schema_override", hint: "Schema override", type: "string", control_type: "text"},
          { name: "dbt_version_override", hint: "DBT version override", type: "string", control_type: "text"},
          { name: "threads_override", hint: "Threads override", type: "integer", control_type: "number"},
          { name: "target_name_override", hint: "Target name override", type: "string", control_type: "text"},
          { name: "generate_docs_override", hint: "Generate docs override", type: "boolean", control_type: "checkbox"},
          { name: "timeout_seconds_override", hint: "Timeout seconds override", type: "integer", control_type: "number"},
          { name: "steps_override", hint: "Steps override", type: "array", control_type: "text"}
        ]
      end,
      execute: lambda do |_connection, input, _extended_input_schema, _extended_output_schema, _continue|
        post("/api/v2/accounts/#{_connection['account_id']}/jobs/#{input['job_id']}/run/")
        .payload(input)
        .after_error_response(/.*/) do |_code, body, _header, message|
          error("#{message}: #{body}")
        end
      end,
      output_fields: lambda do |_object_definitions, _connection, _config_fields|
        [
          { name: "data", type: "object", properties: [
            { name: "id", type: "integer" },
            { name: "trigger_id", type: "integer" },
            { name: "account_id", type: "integer" },
            { name: "environment_id", type: "integer" },
            { name: "project_id", type: "integer" },
            { name: "job_definition_id", type: "integer" },
            { name: "status", type: "integer" },
            { name: "dbt_version", type: "string" },
            { name: "git_branch", type: "string" },
            { name: "git_sha", type: "string" },
            { name: "status_message", type: "string" },
            { name: "owner_thread_id", type: "string" },
            { name: "executed_by_thread_id", type: "string" },
            { name: "deferring_run_id", type: "integer" },
            { name: "artifacts_saved", type: "boolean" },
            { name: "artifact_s3_path", type: "string" },
            { name: "has_docs_generated", type: "boolean" },
            { name: "has_sources_generated", type: "boolean" },
            { name: "notifications_sent", type: "boolean" },
            { name: "blocked_by", type: "array", of: "integer" },
            { name: "scribe_enabled", type: "boolean" },
            { name: "created_at", type: "timestamp" },
            { name: "updated_at", type: "timestamp" },
            { name: "dequeued_at", type: "timestamp" },
            { name: "started_at", type: "timestamp" },
            { name: "finished_at", type: "timestamp" },
            { name: "last_checked_at", type: "timestamp" },
            { name: "last_heartbeat_at", type: "timestamp" },
            { name: "should_start_at", type: "timestamp" },
            { name: "job", type: "object", properties: [
              { name: "property1" },
              { name: "property2" }
            ] },
            { name: "environment", type: "object", properties: [
              { name: "property1" },
              { name: "property2" }
            ] },
            { name: "status_humanized", type: "string" },
            { name: "in_progress", type: "boolean" },
            { name: "is_complete", type: "boolean" },
            { name: "is_success", type: "boolean" },
            { name: "is_error", type: "boolean" },
            { name: "is_cancelled", type: "boolean" },
            { name: "duration", type: "string" },
            { name: "queued_duration", type: "string" },
            { name: "run_duration", type: "string" },
            { name: "duration_humanized", type: "string" },
            { name: "queued_duration_humanized", type: "string" },
            { name: "run_duration_humanized", type: "string" },
            { name: "created_at_humanized", type: "string" },
            { name: "finished_at_humanized", type: "string" },
            { name: "retrying_run_id", type: "integer" },
            { name: "can_retry", type: "boolean" },
            { name: "retry_not_supported_reason", type: "string" },
            { name: "job_id", type: "integer" },
            { name: "is_running", type: "boolean" },
            { name: "href", type: "string" }
          ] },
          { name: "status", type: "object", properties: [
            { name: "code", type: "integer" },
            { name: "is_success", type: "boolean" },
            { name: "user_message", type: "string" },
            { name: "developer_message", type: "string" }
          ] }
        ]
      end
    },

    retrieve_run: {
      title: "Retrieve Run",
      subtitle: "Retrieve a specific run",
      description: lambda do
        "Retrieve <span class='provider'>Run</span> in <span class='provider'>dbt Cloud</span>"
      end,
      help: lambda do
        "This action retrieves details for a specific run in dbt Cloud."
      end,
      input_fields: lambda do
        [
          { name: 'id', type: 'integer', control_type: 'number', optional: false, hint: 'Run ID' },
          { name: 'created_at__range', type: 'array', control_type: 'text', optional: true, hint: 'Created at range', sticky: false },
          { name: 'dbt_version', type: 'string', control_type: 'text', optional: true, hint: 'DBT version', sticky: false },
          { name: 'dbt_version__in', type: 'array', control_type: 'text', optional: true, hint: 'DBT version in', sticky: false },
          { name: 'deferring_run_id', type: 'integer', control_type: 'number', optional: true, hint: 'Deferring run ID', sticky: false },
          { name: 'environment_id', type: 'integer', control_type: 'number', optional: true, hint: 'Environment ID', sticky: false },
          { name: 'finished_at__range', type: 'array', control_type: 'text', optional: true, hint: 'Finished at range', sticky: false },
          { name: 'has_docs_generated', type: 'boolean', control_type: 'checkbox', optional: true, hint: 'Has docs generated', sticky: false },
          { name: 'has_sources_generated', type: 'boolean', control_type: 'checkbox', optional: true, hint: 'Has sources generated', sticky: false },
          { name: 'id__gt', type: 'integer', control_type: 'number', optional: true, hint: 'ID greater than', sticky: false },
          { name: 'job_definition_id', type: 'integer', control_type: 'number', optional: true, hint: 'Job definition ID', sticky: false },
          { name: 'limit', type: 'integer', control_type: 'number', optional: true, hint: 'Limit', sticky: false },
          { name: 'offset', type: 'integer', control_type: 'number', optional: true, hint: 'Offset', sticky: false },
          { name: 'pk', type: 'integer', control_type: 'number', optional: true, hint: 'Primary key', sticky: false },
          { name: 'project_id', type: 'integer', control_type: 'number', optional: true, hint: 'Project ID', sticky: false },
          { name: 'project_id__in', type: 'array', control_type: 'text', optional: true, hint: 'Project ID in', sticky: false },
          { name: 'state', type: 'integer', control_type: 'number', optional: true, hint: 'State', sticky: false },
          { name: 'status', type: 'integer', control_type: 'number', optional: true, hint: 'Status', sticky: false },
          { name: 'status__in', type: 'array', control_type: 'text', optional: true, hint: 'Status in', sticky: false }
        ]
      end,
      execute: lambda do |connection, input|
        get("/api/v2/accounts/#{connection['account_id']}/runs/#{input['id']}/").
          after_error_response(/.*/) do |code, body, header, message|
            error("#{message}: #{body}")
          end
      end,
      output_fields: lambda do
        [
          { name: 'data', type: 'object', properties: [
            { name: 'id', type: 'integer' },
            { name: 'trigger_id', type: 'integer' },
            { name: 'account_id', type: 'integer' },
            { name: 'environment_id', type: 'integer' },
            { name: 'project_id', type: 'integer' },
            { name: 'job_definition_id', type: 'integer' },
            { name: 'status', type: 'integer' },
            { name: 'dbt_version', type: 'string' },
            { name: 'git_branch', type: 'string' },
            { name: 'git_sha', type: 'string' },
            { name: 'status_message', type: 'string' },
            { name: 'owner_thread_id', type: 'string' },
            { name: 'executed_by_thread_id', type: 'string' },
            { name: 'deferring_run_id', type: 'integer' },
            { name: 'artifacts_saved', type: 'boolean' },
            { name: 'artifact_s3_path', type: 'string' },
            { name: 'has_docs_generated', type: 'boolean' },
            { name: 'has_sources_generated', type: 'boolean' },
            { name: 'notifications_sent', type: 'boolean' },
            { name: 'blocked_by', type: 'array' },
            { name: 'scribe_enabled', type: 'boolean' },
            { name: 'created_at', type: 'date_time' },
            { name: 'updated_at', type: 'date_time' },
            { name: 'dequeued_at', type: 'date_time' },
            { name: 'started_at', type: 'date_time' },
            { name: 'finished_at', type: 'date_time' },
            { name: 'last_checked_at', type: 'date_time' },
            { name: 'last_heartbeat_at', type: 'date_time' },
            { name: 'should_start_at', type: 'date_time' },
            { name: 'job', type: 'object', properties: [
              { name: 'property1' },
              { name: 'property2' }
            ]},
            { name: 'environment', type: 'object', properties: [
              { name: 'property1' },
              { name: 'property2' }
            ]},
            { name: 'status_humanized', type: 'string' },
            { name: 'in_progress', type: 'boolean' },
            { name: 'is_complete', type: 'boolean' },
            { name: 'is_success', type: 'boolean' },
            { name: 'is_error', type: 'boolean' },
            { name: 'is_cancelled', type: 'boolean' },
            { name: 'duration', type: 'string' },
            { name: 'queued_duration', type: 'string' },
            { name: 'run_duration', type: 'string' },
            { name: 'duration_humanized', type: 'string' },
            { name: 'queued_duration_humanized', type: 'string' },
            { name: 'run_duration_humanized', type: 'string' },
            { name: 'created_at_humanized', type: 'string' },
            { name: 'finished_at_humanized', type: 'string' },
            { name: 'retrying_run_id', type: 'integer' },
            { name: 'can_retry', type: 'boolean' },
            { name: 'retry_not_supported_reason', type: 'string' },
            { name: 'job_id', type: 'integer' },
            { name: 'is_running', type: 'boolean' },
            { name: 'href', type: 'string' }
          ]},
          { name: 'status', type: 'object', properties: [
            { name: 'code', type: 'integer' },
            { name: 'is_success', type: 'boolean' },
            { name: 'user_message', type: 'string' },
            { name: 'developer_message', type: 'string' }
          ]}
        ]
      end
    },

    retry_run: {
      title: "Retry Run",
      subtitle: "Retry a failed run",
      description: lambda do |input, picklist_label|
        "Retry <span class='provider'>run</span> in <span class='provider'>dbt Cloud</span>"
      end,
      help: lambda do |input, picklist_label|
        "This action retries a failed run in dbt Cloud. After the run has completed, users can use the Get Run Artifact endpoint to download artifacts generated by the run."
      end,
      input_fields: lambda do |object_definitions, connection, config_fields|
        [
          { name: 'run_id', hint: 'Run ID', type: 'integer', control_type: 'number', optional: false, sticky: true }
        ]
      end,
      execute: lambda do |connection, input, extended_input_schema, extended_output_schema, continue|
        post("/api/v2/accounts/#{connection['account_id']}/runs/#{input['run_id']}/retry/")
        .after_error_response(/.*/) do |code, body, header, message|
          error("#{message}: #{body}")
        end
      end,
      output_fields: lambda do |object_definitions, connection, config_fields|
        [
          { name: 'data', type: 'object', properties: [
            { name: 'property1', type: 'string' },
            { name: 'property2', type: 'string' }
          ]},
          { name: 'status', type: 'object', properties: [
            { name: 'code', type: 'integer' },
            { name: 'is_success', type: 'boolean' },
            { name: 'user_message', type: 'string' },
            { name: 'developer_message', type: 'string' }
          ]}
        ]
      end
    }
  },

  triggers: {
    run_event: {
      title: 'Run Event',
      subtitle: "Triggers when run event is created",
      description: "Triggers when a dbt Cloud job run event is created. This can be run.started, run.completed or run.errored",

      input_fields: lambda do
        [
          { name: "event_type", 
            control_type: 'select', optional: false,
            pick_list: [
              ['Run started', 'job.run.started'],
              ['Run completed', 'job.run.completed'],
              ['Run errored', 'job.run.errored']
            ]
          }
        ]
      end,

      webhook_subscribe: lambda do |webhook_url, connection, input, recipe_id|
        # Use dbt Cloud API to create a webhook subscription
        res = post("/api/v3/accounts/#{connection['account_id']}/webhooks/subscriptions",
          {
            "event_types": ["#{input['event_type']}"],
            "name": "Workato Recipe #{recipe_id} #{input['event_type']}",
            "client_url": webhook_url,
            "active": true
            # Include other necessary parameters like job_ids if needed
          }).after_error_response(/.*/) do |code, body, header, message|
            error("#{message}: #{body}: #{header}: #{code}")
          end

        { id: res['data']['id']}
      end,

      webhook_notification: lambda do |input, payload|
        payload
      end,

      webhook_unsubscribe: lambda do |webhook_subscribe_output, connection|
        subId = webhook_subscribe_output['id']
        delete("/api/v3/accounts/239750/webhooks/subscription/#{subId}")
      end,

      dedup: lambda do |message|
        message["eventId"]
      end,

      output_fields: lambda do
        [
          {
            control_type: "text",
            label: "Webhooks ID",
            type: "string",
            name: "webhooksID"
          },
          {
            control_type: "text",
            label: "Event ID",
            type: "string",
            name: "eventId"
          },
          {
            properties: [
              {
                control_type: "text",
                label: "Job ID",
                type: "string",
                name: "jobId"
              },
              {
                control_type: "text",
                label: "Job name",
                type: "string",
                name: "jobName"
              },
              {
                control_type: "text",
                label: "Run ID",
                type: "string",
                name: "runId"
              },
              {
                control_type: "text",
                label: "Environment ID",
                type: "string",
                name: "environmentId"
              },
              {
                control_type: "text",
                label: "Environment name",
                type: "string",
                name: "environmentName"
              },
              {
                control_type: "text",
                label: "Dbt version",
                type: "string",
                name: "dbtVersion"
              },
              {
                control_type: "text",
                label: "Project name",
                type: "string",
                name: "projectName"
              },
              {
                control_type: "text",
                label: "Project ID",
                type: "string",
                name: "projectId"
              },
              {
                control_type: "text",
                label: "Run status",
                type: "string",
                name: "runStatus"
              },
              {
                control_type: "number",
                label: "Run status code",
                parse_output: "float_conversion",
                type: "number",
                name: "runStatusCode"
              },
              {
                control_type: "text",
                label: "Run status message",
                type: "string",
                name: "runStatusMessage"
              },
              {
                control_type: "text",
                label: "Run reason",
                type: "string",
                name: "runReason"
              },
              {
                control_type: "text",
                label: "Run started at",
                render_input: "date_time_conversion",
                parse_output: "date_time_conversion",
                type: "date_time",
                name: "runStartedAt"
              }
            ],
            label: "Data",
            type: "object",
            name: "data"
          }
        ]
      end
    }
  }
}
