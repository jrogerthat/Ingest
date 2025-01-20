defmodule Ingest.Repo.Migrations.SearchRpAgain do
  use Ecto.Migration

  def change do
    # Drop the existing virtual table
    execute "DROP TABLE IF EXISTS request_project_search;"

    # Recreate the virtual table with the new column
    execute """
    CREATE VIRTUAL TABLE request_project_search USING fts5(
      id, project_id, name, project_name, description, tokenize='trigram',
      content='requests', content_rowid='rowid'
    );
    """

    # Drop the existing trigger for request_project_search
    execute "DROP TRIGGER IF EXISTS t1_ai_request_project_search;"

    # Recreate the trigger to accommodate the new column
    execute """
    CREATE TRIGGER t1_ai_request_project_search AFTER INSERT ON requests BEGIN
      INSERT INTO request_project_search(rowid, id, project_id, name, project_name, description)
      VALUES (new.rowid, new.id, new.project_id, new.name, (SELECT name FROM projects WHERE id = new.project_id), new.description);
    END;
    """

    # Create additional triggers for update and delete if necessary
    execute "DROP TRIGGER IF EXISTS t1_au_request_project_search;"
    execute """
    CREATE TRIGGER t1_au_request_project_search AFTER UPDATE ON requests BEGIN
      INSERT INTO request_project_search(request_project_search, rowid, id, project_id, name, project_name, description)
      VALUES ('delete', old.rowid, old.id, old.project_id, old.name, (SELECT name FROM projects WHERE id = old.project_id), old.description);
      INSERT INTO request_project_search(rowid, id, project_id, name, project_name, description)
      VALUES (new.rowid, new.id, new.project_id, new.name, (SELECT name FROM projects WHERE id = new.project_id), new.description);
    END;
    """

    execute "DROP TRIGGER IF EXISTS t1_ad_request_project_search;"
    execute """
    CREATE TRIGGER t1_ad_request_project_search AFTER DELETE ON requests BEGIN
      INSERT INTO request_project_search(request_project_search, rowid, id, project_id, name, project_name, description)
      VALUES ('delete', old.rowid, old.id, old.project_id, old.name, (SELECT name FROM projects WHERE id = old.project_id), old.description);
    END;
    """
  end
end
