defmodule Ingest.Repo.Migrations.CreateCompositeSearchTable do
  use Ecto.Migration

  def change do
    # Drop the existing virtual table if it exists
    execute "DROP TABLE IF EXISTS composite_search;"

    # Create the composite virtual table with fields from both requests and projects
    execute """
    CREATE VIRTUAL TABLE composite_search USING fts5(
      id, type, project_id, name, project_name, description, tokenize='trigram'
    );
    """

    # Drop the existing triggers for composite_search if they exist
    execute "DROP TRIGGER IF EXISTS t1_ai_composite_search_requests;"
    execute "DROP TRIGGER IF EXISTS t1_ai_composite_search_projects;"

    # Create the trigger to insert data into the composite search table for requests
    execute """
    CREATE TRIGGER t1_ai_composite_search_requests AFTER INSERT ON requests BEGIN
      INSERT INTO composite_search(id, type, project_id, name, project_name, description)
      VALUES (new.id, 'request', new.project_id, new.name, (SELECT name FROM projects WHERE projects.id = new.project_id), new.description);
    END;
    """

    # Create the trigger to insert data into the composite search table for projects
    execute """
    CREATE TRIGGER t1_ai_composite_search_projects AFTER INSERT ON projects BEGIN
      INSERT INTO composite_search(id, type, project_id, name, project_name, description)
      VALUES (new.id, 'project', new.id, new.name, new.name, new.description);
    END;
    """

    # Drop the existing triggers for updates if they exist
    execute "DROP TRIGGER IF EXISTS t1_au_composite_search_requests;"
    execute "DROP TRIGGER IF EXISTS t1_au_composite_search_projects;"

    # Create the trigger to update data in the composite search table for requests
    execute """
    CREATE TRIGGER t1_au_composite_search_requests AFTER UPDATE ON requests BEGIN
      INSERT INTO composite_search(composite_search, id, type, project_id, name, project_name, description)
      VALUES ('delete', old.id, 'request', old.project_id, old.name, (SELECT name FROM projects WHERE projects.id = old.project_id), old.description);
      INSERT INTO composite_search(id, type, project_id, name, project_name, description)
      VALUES (new.id, 'request', new.project_id, new.name, (SELECT name FROM projects WHERE projects.id = new.project_id), new.description);
    END;
    """

    # Create the trigger to update data in the composite search table for projects
    execute """
    CREATE TRIGGER t1_au_composite_search_projects AFTER UPDATE ON projects BEGIN
      INSERT INTO composite_search(composite_search, id, type, project_id, name, project_name, description)
      VALUES ('delete', old.id, 'project', old.id, old.name, old.description);
      INSERT INTO composite_search(id, type, project_id, name, project_name, description)
      VALUES (new.id, 'project', new.id, new.name, new.name, new.description);
    END;
    """

    # Drop the existing triggers for deletes if they exist
    execute "DROP TRIGGER IF EXISTS t1_ad_composite_search_requests;"
    execute "DROP TRIGGER IF EXISTS t1_ad_composite_search_projects;"

    # Create the trigger to delete data in the composite search table for requests
    execute """
    CREATE TRIGGER t1_ad_composite_search_requests AFTER DELETE ON requests BEGIN
      INSERT INTO composite_search(composite_search, id, type, project_id, name, project_name, description)
      VALUES ('delete', old.id, 'request', old.project_id, old.name, (SELECT name FROM projects WHERE projects.id = old.project_id), old.description);
    END;
    """

    # Create the trigger to delete data in the composite search table for projects
    execute """
    CREATE TRIGGER t1_ad_composite_search_projects AFTER DELETE ON projects BEGIN
      INSERT INTO composite_search(composite_search, id, type, project_id, name, project_name, description)
      VALUES ('delete', old.id, 'project', old.id, old.name, old.name, old.description);
    END;
    """
  end
end
