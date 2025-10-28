def upload_to_database(
    file_path: str, supabase_url: str, supabase_key: str, bucket: str, remote_path: str
) -> dict:
    """
    Upload file to Supabase Storage using the REST API.
    NOTE: This requires the anon/service role key with storage permissions.
    Parameters:
      - file_path: local path to file
      - supabase_url: your supabase project url, e.g. https://xxxxx.supabase.co
      - supabase_key: service role key or anon key with rights
      - bucket: bucket name in Supabase storage
      - remote_path: path (filename) within the bucket
    Returns:
      response dict (status_code and text)
    """
    import requests

    url = f"{supabase_url}/storage/v1/object/{bucket}/{remote_path}"
    headers = {
        "Authorization": f"Bearer {supabase_key}",
        "Content-Type": "application/octet-stream",
    }
    with open(file_path, "rb") as fh:
        resp = requests.post(url, headers=headers, data=fh)
    return {"status_code": resp.status_code, "text": resp.text}
