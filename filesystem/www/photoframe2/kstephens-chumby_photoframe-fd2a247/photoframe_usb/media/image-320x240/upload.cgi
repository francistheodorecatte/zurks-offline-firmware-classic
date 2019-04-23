#!/usr/bin/env ruby
# -*- ruby -*-

dst_dir = File.expand_path(".")
file_range = (1 .. 10)

content = ''
content_footer = ''

begin
  # ruby script fragment
  require 'cgi'
  # require 'stringio' # not in 1.8.4?

  def h *args
    CGI::escapeHTML(args * " ")
  end


  cgi = CGI.new()  # New CGI object

  # Collect file params.
  files = [ ]
  file_range.each do | i |
    param = cgi.params["file#{i}"]
    if param && ! param.empty? && (x = param.first.original_filename) && ! x.empty?
      files << { :i => i, :param => param }
    end
  end

  # $stderr.puts "files = #{files.inspect}"

  files.each do | file |
    param = file[:param]

    # get uri of tx'd file (in tmp normally)
    tmpfile = param.first.path
    
    # create a Tempfile reference
    fromfile = param.first
  
    file[:src_file] = fromfile.original_filename
    file[:content_type] = fromfile.content_type
  
    file[:dst_file] = "#{dst_dir}/#{File.basename(file[:src_file])}"
 
    unless file[:dst_file] =~ /\.(jpe?g|png)$/i
      file[:error] = "bad filename"
      next
    end

    # note the untaint prevents a security error
    file[:dst_file] = file[:dst_file].untaint
    
    # copy the file
    # cgi sets up an StringIO object if file < 10240
    # or a Tempfile object following works for both
    File.open(file[:dst_file], 'w') { | out | out << fromfile.read }
    # when the page finishes the Tempfile/StringIO!) thing is deleted automatically
    
    file[:size] = File.size(file[:dst_file])
  end

  # Update images.xml.
  unless files.empty?
    content_footer = `make-images 2>&1`
  end

  # Generate form.
  content << <<"END"
<form name="fileupload" 
      enctype="multipart/form-data" 
      action="#{File.basename($0)}" 
      method="post">
END
  file_range.each do | i |
    content << <<"END"
   <input type="file" name="file#{i}" size="50" /><br />
END
    if file = files.find { | file | file[:i] == i }
      if file[:error]
        content << <<"END"
<pre>
  ERROR:        #{h file[:error]}
</pre>
END
      end
      content << <<"END"
<pre>
  source:       #{h file[:src_file]}
  destination:  #{h file[:dst_file]}
  content type: #{h file[:content_type]}
  size:         #{h file[:size]}
</pre>
<br />
END
    end
  end

  content << <<"END"
   <input type="submit" value="Send files" /><br />
</form>
END

rescue Exception => err
  # Generate error content.
  content << <<"END"
<pre>
ERROR: #{h err.inspect}
  #{h err.backtrace * "\n  "}"
</pre>"
END
end

# Render HTML.
puts <<"END"
Content-Type: text/html

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <title>Image upload</title>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
  </head>
  <body>
    <p>Image upload</p>
  #{content}
<br />
<hr />
<pre>
  #{h content_footer}
</pre>
  </body>
</html>
END

exit 0


