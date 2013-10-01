def delete_file!(file)
  File.delete file if File.exists? file
end