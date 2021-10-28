#!/usr/bin/env ruby

# frozen_string_literal: false

require_relative './option'
require_relative './path_info'
require_relative './long_format_block'
require_relative './normal_format_block'
require_relative './dir_block'

class Ls
  attr_reader :result

  def initialize
    @option = Option.new
    @result = make_result
  end

  private

  def make_result
    path_info = PathInfo.new(option.reverse?)
    noent_section = make_noent_section(path_info.paths_not_exist)
    body_blocks = make_body_blocks(path_info, option)
    body_section = make_body_section(body_blocks)
    "#{noent_section}#{body_section}"
  end

  def make_body_blocks(path_info, option)
    files_block = option.long_format? ? LongFormatBlock.new(path_info.files, '.') : NormalFormatBlock.new(path_info.files)
    dir_blocks = DirBlock.make_arr(path_info.directories, option)
    files_block.data.length.positive? ? dir_blocks.unshift(files_block) : dir_blocks
  end

  def make_body_section(body_blocks)
    body_blocks.map(&:data).join("\n")
  end

  def make_noent_section(paths_not_exist)
    section = ''
    paths_not_exist.each do |path|
      section << "ls: #{path}: No such file or directory\n"
    end
    section
  end

  attr_reader :option
end

if __FILE__ == $PROGRAM_NAME # rubocop:disable Style/IfUnlessModifier
  puts Ls.new.result
end
