# Copyright (C) 2003, 2004, 2005, 2006, 2007 Gregoire Lejeune <gregoire.lejeune@free.fr>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA

require 'tempfile'
#require 'mkmf'

require 'graphviz/node'
require 'graphviz/edge'
require 'graphviz/attrs'
require 'graphviz/constants'
require 'graphviz/parser'

class GraphViz 
  include Constants

  public

  ## Var: Output format (dot, png, jpeg, ...)
  @@format = nil #"canon"
  @format
  ## Var: Output file name
  @filename
  ## Var: Output format and file
  @output
  ## Var: program to use (dot|twopi)
  @@prog = "dot"
  @prog
  ## Var: program path
  @@path = nil
  @path
  ## Var: Error level
  @@errors = 1
  @errors
  
  ## Var: Graph name
  @name

  ## Var: defined attributs
  @graph
  @node
  @edge
  
  # This accessor allow you to set global nodes attributs
  attr_accessor :node

  # This accessor allow you to set global edges attributs
  attr_accessor :edge

  @elements_order
  
  ##
  # Create a new node
  #
  # In:
  # * xNodeName : Name of the new node
  # * *hOpt : Node attributs
  # 
  # Return the GraphViz::Node object created
  #
  def add_node( xNodeName, *hOpt )
    @hoNodes[xNodeName] = GraphViz::Node::new( xNodeName, self )
   
    if hOpt.nil? == false and hOpt[0].nil? == false
      hOpt[0].each do |xKey, xValue|
        @hoNodes[xNodeName][xKey.to_s] = xValue
      end
    end

    @elements_order.push( { 
      "type" => "node", 
      "name" => xNodeName,
      "value" => @hoNodes[xNodeName] 
    } )
    
    return( @hoNodes[xNodeName] )
  end

  #
  # Return the node object for the given name (or nil)
  #
  def get_node( xNodeName, &block )
    node = @hoNodes[xNodeName] || nil
    
    yield( node ) if( block and node.nil? == false )
    
    return node
  end
  
  ##
  # Create a new edge
  # 
  # In:
  # * oNodeOne : First node (or node list)
  # * oNodeTwo : Second Node (or node list)
  # * *hOpt : Edge attributs
  #
  def add_edge( oNodeOne, oNodeTwo, *hOpt )
    
    if( oNodeOne.class == Array ) 
      oNodeOne.each do |no|
        add_edge( no, oNodeTwo, *hOpt )
      end
    else
      if( oNodeTwo.class == Array )
        oNodeTwo.each do |nt|
          add_edge( oNodeOne, nt, *hOpt )
        end
      else

        oEdge = GraphViz::Edge::new( oNodeOne, oNodeTwo, self )
        
        if hOpt.nil? == false and hOpt[0].nil? == false
          hOpt[0].each do |xKey, xValue|
            oEdge[xKey.to_s] = xValue
          end
        end

        @elements_order.push( { 
          "type" => "edge", 
          "value" => oEdge
        } )
        @loEdges.push( oEdge )
        
        return( oEdge )
      end
    end
  end

  # 
  # Create a new graph
  # 
  # In:
  # * xGraphName : Graph name
  # * *hOpt : Graph attributs
  #
  def add_graph( xGraphName, *hOpt )
    @hoGraphs[xGraphName] = GraphViz::new( xGraphName, :parent => self, :type => @oGraphType )
   
    if hOpt.nil? == false and hOpt[0].nil? == false
      hOpt[0].each do |xKey, xValue|
        @hoGraphs[xGraphName][xKey.to_s] = xValue
      end
    end

    @elements_order.push( { 
      "type" => "graph", 
      "name" => xGraphName,
      "value" => @hoGraphs[xGraphName] 
    } )
    
    return( @hoGraphs[xGraphName] )
  end
  
  #
  # Return the graph object for the given name (or nil)
  #
  def get_graph( xGraphName, &block )
    graph = @hoGraphs[xGraphName] || nil
    
    yield( graph ) if( block and graph.nil? == false )
    
    return graph
  end
  
  #
  # Get the number of nodes
  #
  def node_count
    @hoNodes.size
  end
  
  #
  # Get the number of edges
  #
  def edge_count
    @loEdges.size
  end
  
  def method_missing( idName, *args, &block ) #:nodoc:
    xName = idName.id2name
  
    rCod = nil
    
    if block
      # Creating a cluster named '#{xName}'
      rCod = add_graph( xName, args[0] )
      yield( rCod )
    else
      # Create a node named '#{xName}' or search for a node, edge or cluster
      if @hoNodes.keys.include?( xName )
        if( args[0] )
          return "#{xName}:#{args[0].to_s}"
        else
          return( @hoNodes[xName] ) 
        end
      end
      return( @hoGraphs[xName] ) if @hoGraphs.keys.include?( xName )
      
      rCod = add_node( xName, args[0] )
    end

    return rCod
  end
  
  # 
  # Set value +xValue+ to the graph attribut +xAttrName+
  # 
  def []=( xAttrName, xValue )
    xValue = xValue.to_s if xValue.class == Symbol
    @graph[xAttrName] = xValue
  end

  # 
  # Get the value of the graph attribut +xAttrName+
  # 
  def []( xAttrName )
    return( @graph[xAttrName].clone )
  end
  
  # 
  # Generate the graph
  # 
  # Options :
  # * :output : Output format (Constants::FORMATS)
  # * :file : Output file name
  # * :use : Program to use (Constants::PROGRAMS)
  # * :path : Program PATH
  # * :<format> => <file> : <file> can be
  #   * a file name
  #   * nil, then the output will be printed to STDOUT
  #   * String, then the output will be returned as a String
  # * :errors : DOT error level (default 1)
  #   * 0 = Error + Warning
  #   * 1 = Error
  #   * 2 = none
  # 
  def output( *hOpt )
    xDOTScript = ""
    xLastType = nil
    xSeparator = ""
    xData = ""

    @elements_order.each { |kElement|
      if xLastType.nil? == true or xLastType != kElement["type"]
        
        if xData.length > 0 
          case xLastType
            when "graph_attr"
              xDOTScript << "  " + xData + ";\n"
  
            when "node_attr"
              xDOTScript << "  node [" + xData + "];\n"
            
            when "edge_attr"
              xDOTScript << "  edge [" + xData + "];\n"
          end
        end
        
        xSeparator = ""
        xData = ""
      end

      xLastType = kElement["type"]

      #Modified by
      #Brandon Coleman 
      #verify value is NOT NULL
      if kElement["value"] == nil then
        raise ArgumentError, "#{kElement["name"]} has a nil value!"
      end

      case kElement["type"]
        when "graph_attr"
          xData << xSeparator + kElement["name"] + " = \"" + kElement["value"] + "\""
          xSeparator = "; "

        when "node_attr"
          xData << xSeparator + kElement["name"] + " = \"" + kElement["value"] + "\""
          xSeparator = ", "

        when "edge_attr"
          xData << xSeparator + kElement["name"] + " = \"" + kElement["value"] + "\""
          xSeparator = ", "

        when "node"
          xDOTScript << "  " + kElement["value"].output() + "\n"

        when "edge"
          xDOTScript << "  " + kElement["value"].output( @oGraphType ) + "\n"

        when "graph"
          xDOTScript << kElement["value"].output() + "\n"

        else
          raise ArgumentError, "Don't know what to do with element type '#{kElement['type']}'"
      end
    }
    
    if xData.length > 0 
      case xLastType
        when "graph_attr"
          xDOTScript << "  " + xData + ";\n"

        when "node_attr"
          xDOTScript << "  node [" + xData + "];\n"
        
        when "edge_attr"
          xDOTScript << "  edge [" + xData + "];\n"
      end
    end
    xDOTScript << "}"

    if @oParentGraph.nil? == false
      xDOTScript = "subgraph #{@name} {\n" << xDOTScript

      return( xDOTScript )
    else
      if hOpt.nil? == false and hOpt[0].nil? == false
        hOpt[0].each do |xKey, xValue|
          xValue = xValue.to_s unless xValue.nil? or [Class, TrueClass, FalseClass].include?(xValue.class)
          case xKey.to_s
            when "output"
              warn ":output option is deprecated, please use :<format> => :<file>"
              if FORMATS.index( xValue ).nil? == true
                raise ArgumentError, "output format '#{xValue}' invalid"
              end
              @format = xValue
            when "file"
              warn ":file option is deprecated, please use :<format> => :<file>"
              @filename = xValue
            when "use"
              if PROGRAMS.index( xValue ).nil? == true
                raise ArgumentError, "can't use '#{xValue}'"
              end
              @prog = xValue
            when "path"
              @path = xValue
            when "errors"
              @errors = xValue
            else
              if FORMATS.index( xKey.to_s ).nil? == true
                raise ArgumentError, "output format '#{xValue}' invalid"
              end
              @output[xKey.to_s] = xValue
          end
        end
      end
  
      xDOTScript = "#{@oGraphType} #{@name} {\n" << xDOTScript

      xOutputString = false
      xOutput = if @format != "none"
        ## Act: Save script and send it to dot
        t = if /Windows/.match( ENV['OS'] )
          Tempfile::open( File.basename($0), "." )
        else
          Tempfile::open( File.basename($0) )
        end
        t.print( xDOTScript )
        t.close
        
        cmd = find_executable( )
        if cmd == nil
          raise StandardError, "GraphViz not installed or #{@prog} not in PATH. Install GraphViz or use the 'path' option"
        end
        
        xOutputWithFile = ""
        xOutputWithoutFile = ""
        unless @format.nil?
          if @filename.nil?
            xOutputWithoutFile = "-T#{@format} "
          elsif @filename == String
            xOutputWithoutFile = "-T#{@format} "
            xOutputString = true
          else
            xOutputWithFile = "-T#{@format} -o#{@filename} "
          end
        end
        @output.each do |format, file|
          if file.nil?
            xOutputWithoutFile << "-T#{format} "
          elsif file == String
            xOutputWithoutFile << "-T#{format} "
            xOutputString = true
          else
            xOutputWithFile << "-T#{format} -o#{file} "
          end
        end
        
        #xCmd = "#{cmd} #{xOutputWithFile} #{xOutputWithoutFile} #{t.path}"
        #if /Windows/.match( ENV['OS'] )
          xCmd = "\"#{cmd}\" -q#{@errors} #{xOutputWithFile} #{xOutputWithoutFile} #{t.path}"
        #end

        output_from_command( xCmd )
      else
        xDOTScript
      end
            
      if xOutputString
        xOutput
      else
        print xOutput
      end
    end
  end
  
  alias :save :output
  
  def output_and_errors_from_command(cmd) #:nodoc:
   unless defined? Open3
     begin
       require 'open3'
       require 'win32/open3'
     rescue LoadError
     end
   end
   begin
     Open3.popen3( cmd ) do |stdin, stdout, stderr|
       stdin.close
       [stdout.read, stderr.read]
     end
   rescue NotImplementedError, NoMethodError
     IO.popen( cmd ) do |stdout|
       [stdout.read, nil]
     end
   end
  end

  def output_from_command(cmd) #:nodoc:
   output, errors = output_and_errors_from_command(cmd)
   if errors.nil? || errors.strip.empty?
     output
   else
     raise "Error from #{cmd}:\n#{errors}"
   end
  end
  
  # 
  # Get the graph name
  #
  def name 
    @name.clone
  end
  
  # 
  # Create an edge between the current cluster and the node or cluster +oNode+
  # 
  def <<( oNode )
    raise( ArgumentError, "Edge between root graph and node or cluster not allowed!" ) if self.pg.nil?

    if( oNode.class == Array ) 
      oNode.each do |no|
        self << no
      end
    else
      return GraphViz::commonGraph( oNode, self ).add_edge( self, oNode )
    end
  end
  alias :> :<<
  alias :- :<<
  alias :>> :<<
  
  def pg #:nodoc:
    @oParentGraph
  end
  
  def self.commonGraph( o1, o2 ) #:nodoc:
    g1 = o1.pg
    g2 = o2.pg

    return o1 if g1.nil?
    return o2 if g2.nil?
    
    return g1 if g1.object_id == g2.object_id
    
    return GraphViz::commonGraph( g1, g2 )
  end
  
  def set_position( xType, xKey, xValue ) #:nodoc:
    @elements_order.push( { 
      "type" => "#{xType}_attr", 
      "name" => xKey,
      "value" => xValue 
    } )
  end
  
## ----------------------------------------------------------------------------

  #
  # Change default options (:use, :path, :errors and :output)
  # 
  def self.default( hOpts )
    hOpts.each do |k, v|
      case k.to_s
        when "use"
          @@prog = v
        when "path"
          @@path = v
        when "errors"
          @@errors = v
        when "output"
          warn ":output option is deprecated!"
          @@format = v
        else
          warn "Invalide option #{k}!"
      end
    end
  end
  
  def self.options( hOpts )
    GraphViz::default( hOpts )
  end
  
## ----------------------------------------------------------------------------

  # 
  # Create a new graph from a GraphViz File
  # 
  # Options :
  # * :output : Output format (Constants::FORMATS) (default : dot)
  # * :file : Output file name (default : none)
  # * :use : Program to use (Constants::PROGRAMS) (default : dot)
  # * :path : Program PATH
  # * :parent : Parent graph (default : none)
  # * :type : Graph type (Constants::GRAPHTYPE) (default : digraph)
  # 
  def self.parse( xFile, *hOpts, &block )
    g = GraphViz::Parser.parse( xFile, hOpts[0], &block )
    return g
  end

## ----------------------------------------------------------------------------

  private 

  ## Var: Nodes, Edges and Graphs tables
  @hoNodes
  @loEdges
  @hoGraphs

  ## Var: Parent graph
  @oParentGraph

  ## Var: Type de graphe (orienté ou non)
  @oGraphType
  
  # 
  # Create a new graph object
  # 
  # Options :
  # * :output : Output format (Constants::FORMATS) (default : dot)
  # * :file : Output file name (default : none)
  # * :use : Program to use (Constants::PROGRAMS) (default : dot)
  # * :path : Program PATH
  # * :parent : Parent graph (default : none)
  # * :type : Graph type (Constants::GRAPHTYPE) (default : digraph)
  # * :errors : DOT error level (default 1)
  #   * 0 = Error + Warning
  #   * 1 = Error
  #   * 2 = none
  # 
  def initialize( xGraphName, *hOpt, &block )
    @filename = nil
    @name     = xGraphName.to_s
    @format   = @@format
    @prog     = @@prog
    @path     = @@path
    @errors   = @@errors
    @output   = {}
    
    @elements_order = Array::new()

    @oParentGraph = nil
    @oGraphType   = "digraph"
    
    @hoNodes  = Hash::new()
    @loEdges  = Array::new()
    @hoGraphs = Hash::new()
    
    @node  = GraphViz::Attrs::new( self, "node",  NODESATTRS  )
    @edge  = GraphViz::Attrs::new( self, "edge",  EDGESATTRS  )
    @graph = GraphViz::Attrs::new( self, "graph", GRAPHSATTRS )

    if hOpt.nil? == false and hOpt[0].nil? == false
      hOpt[0].each do |xKey, xValue|
        case xKey.to_s
          when "output"
            warn ":output option is deprecated, please use :<format> => :<file>"
            if FORMATS.index( xValue.to_s ).nil? == true
              raise ArgumentError, "output format '#{xValue}' invalid"
            end
            @format = xValue.to_s
          when "use"
            if PROGRAMS.index( xValue.to_s ).nil? == true
              raise ArgumentError, "can't use '#{xValue}'"
            end
            @prog = xValue.to_s
          when "file"
            warn ":file option is deprecated, please use :<format> => :<file>"
            @filename = xValue.to_s
          when "parent"
            @oParentGraph = xValue
          when "type"
            if GRAPHTYPE.index( xValue.to_s ).nil? == true
              raise ArgumentError, "graph type '#{xValue}' unknow"
            end
            @oGraphType = xValue.to_s
          when "path"
            @path = xValue.to_s
          when "errors"
            @errors = xValue
          else
            self[xKey.to_s] = xValue.to_s
        end
      end
    end
  
    yield( self ) if( block )
  end
  
  #
  # Escape a string to be acceptable as a node name in a graphviz input file
  #
  def self.escape(str, force = false) #:nodoc:
    if force or str.match( /\A[a-zA-Z_]+[a-zA-Z0-9_:\.]*\Z/ ).nil?
      '"' + str.gsub('"', '\\"').gsub("\n", '\\\\n') + '"' 
    else
      str
    end
  end
  
  def find_executable( ) #:nodoc:
    cmd = find_executable0( @prog )
    if cmd == nil and @path != nil
      __cmd = File.join( @path, @prog )
      cmd = __cmd if File.executable?( __cmd )
    end
    return cmd
  end
end

