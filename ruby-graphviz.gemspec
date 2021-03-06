# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-graphviz}
  s.version = "0.9.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gregoire Lejeune"]
  s.date = %q{2009-11-02}
  s.default_executable = %q{ruby2gv}
  s.description = %q{Ruby/Graphviz provides an interface to layout and generate images of directed graphs in a variety of formats (PostScript, PNG, etc.) using GraphViz.}
  s.email = %q{gregoire.lejeune@free.fr}
  s.executables = ["ruby2gv"]
  s.extra_rdoc_files = [
    "AUTHORS",
     "COPYING",
     "ChangeLog",
     "README.rdoc"
  ]
  s.files = [
    "AUTHORS",
     "COPYING",
     "ChangeLog",
     "README.rdoc",
     "bin/ruby2gv",
     "examples/HTML-Labels.rb",
     "examples/arrowhead.rb",
     "examples/dot/cluster.dot",
     "examples/dot/fsm.dot",
     "examples/dot/genetic.dot",
     "examples/dot/hello.dot",
     "examples/dot/hello_test.rb",
     "examples/dot/lion_share.dot",
     "examples/dot/prof.dot",
     "examples/dot/psg.dot",
     "examples/dot/sdh.dot",
     "examples/dot/siblings.dot",
     "examples/dot/test.dot",
     "examples/dot/unix.dot",
     "examples/graphviz.org/TrafficLights.rb",
     "examples/graphviz.org/cluster.rb",
     "examples/graphviz.org/hello_world.rb",
     "examples/graphviz.org/lion_share.rb",
     "examples/graphviz.org/process.rb",
     "examples/maketest.sh",
     "examples/p2p.rb",
     "examples/sample01.rb",
     "examples/sample02.rb",
     "examples/sample03.rb",
     "examples/sample04.rb",
     "examples/sample05.rb",
     "examples/sample06.rb",
     "examples/sample07.rb",
     "examples/sample08.rb",
     "examples/sample09.rb",
     "examples/sample10.rb",
     "examples/sample11.rb",
     "examples/sample12.rb",
     "examples/sample13.rb",
     "examples/sample14.rb",
     "examples/sample15.rb",
     "examples/sample16.rb",
     "examples/sample17.rb",
     "examples/sample18.rb",
     "examples/sample19.rb",
     "examples/sample20.rb",
     "examples/sample21.rb",
     "examples/sample22.rb",
     "examples/sample23.rb",
     "examples/sample24.rb",
     "examples/sample25.rb",
     "examples/shapes.rb",
     "examples/test.xml",
     "examples/testorder.rb",
     "examples/testxml.rb",
     "lib/graphviz.rb",
     "lib/graphviz/attrs.rb",
     "lib/graphviz/constants.rb",
     "lib/graphviz/dot.treetop",
     "lib/graphviz/edge.rb",
     "lib/graphviz/node.rb",
     "lib/graphviz/parser.rb",
     "lib/graphviz/xml.rb",
     "setup.rb"
  ]
  s.homepage = %q{http://raa.ruby-lang.org/project/ruby-graphviz/}
  s.post_install_message = %q{
Since version 0.9.2, Ruby/GraphViz can use Open3.popen3 (or not)
On Windows, you can install 'win32-open3'

You need to install GraphViz (http://graphviz.org/) to use this Gem.

}
  s.rdoc_options = ["--title", "Ruby/GraphViz", "--main", "README.rdoc", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ruby-asp}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Interface to the GraphViz graphing tool}
  s.test_files = [
    "examples/arrowhead.rb",
     "examples/dot/hello_test.rb",
     "examples/graphviz.org/cluster.rb",
     "examples/graphviz.org/hello_world.rb",
     "examples/graphviz.org/lion_share.rb",
     "examples/graphviz.org/process.rb",
     "examples/graphviz.org/TrafficLights.rb",
     "examples/HTML-Labels.rb",
     "examples/p2p.rb",
     "examples/sample01.rb",
     "examples/sample02.rb",
     "examples/sample03.rb",
     "examples/sample04.rb",
     "examples/sample05.rb",
     "examples/sample06.rb",
     "examples/sample07.rb",
     "examples/sample08.rb",
     "examples/sample09.rb",
     "examples/sample10.rb",
     "examples/sample11.rb",
     "examples/sample12.rb",
     "examples/sample13.rb",
     "examples/sample14.rb",
     "examples/sample15.rb",
     "examples/sample16.rb",
     "examples/sample17.rb",
     "examples/sample18.rb",
     "examples/sample19.rb",
     "examples/sample20.rb",
     "examples/sample21.rb",
     "examples/sample22.rb",
     "examples/sample23.rb",
     "examples/sample24.rb",
     "examples/sample25.rb",
     "examples/shapes.rb",
     "examples/testorder.rb",
     "examples/testxml.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<treetop>, [">= 0"])
    else
      s.add_dependency(%q<treetop>, [">= 0"])
    end
  else
    s.add_dependency(%q<treetop>, [">= 0"])
  end
end

