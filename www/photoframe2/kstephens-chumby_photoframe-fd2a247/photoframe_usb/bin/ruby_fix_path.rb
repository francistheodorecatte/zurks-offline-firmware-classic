# Fix bogus $: paths from chumby_ruby tarball.
$:.map! do | p |
  p.sub("/var/lib/install/usr//", File.expand_path(File.dirname(__FILE__) + '/../ruby_arm') + '/')
end

