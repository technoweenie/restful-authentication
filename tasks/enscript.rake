require 'rubygems'
require 'fileutils'; include FileUtils::Verbose

# You need a copy of the elusive Ruby/Enscript by Mike Wilson: see
# http://neugierig.org/software/ruby/ or http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/154570

task :default => [:enscript_modular, :enscript_mainline, :enscript_ra_ex]

# --file-align=1  --color --media=Letter
ENSCRIPT_ARGS=' --media=LetterGoodAs2Up -G --language=PostScript '
OUTPUT_PATH='/tmp'
#


def sh_enscript src_files, out_file, langflag=''
  #  sh %{ enscript #{ENSCRIPT_ARGS} -p- #{langflag} #{src_files} | psnup -2 > #{OUTPUT_PATH}/#{out_file}  }
  sh %{ enscript #{ENSCRIPT_ARGS} -U2 -p- #{langflag} #{src_files} > #{OUTPUT_PATH}/#{out_file}  }
end

def ruby_files files
  files.reject{|f| (! File.file? f) ||(f !~ /^.*\.(rb|rb)$/) }.join(" ")
end
def text_files files
  files.reject{|f| (! File.file? f) || (f =~ /^.*\.(erb|rb|graffle|png|story)$/) }.join(" ")
end

task :enscript_modular do |t|
  cd File.expand_path('~/ics/plugins/rails/restful_authentication') do
    all_files = Dir['{*,{lib,generators,stories,notes}/**/*}'].uniq
    sh_enscript ruby_files(all_files), 'ra-mo-ruby.ps', " -uMO -Eruby"
    sh_enscript text_files(all_files), 'ra-mo-text.ps', " -uMO "
  end
end

task :enscript_mainline do |t|
  cd File.expand_path('~/ics/plugins/rails/mainline_restful_authentication') do
    all_files = Dir['{*,{lib,generators,stories,notes}/**/*}'].uniq
    sh_enscript ruby_files(all_files), 'ra-ml-ruby.ps', " -uML -Eruby"
    sh_enscript text_files(all_files), 'ra-ml-text.ps', " -uML "
  end
end


task :enscript_ra_ex do |t|
  cd File.expand_path('~/ics/apps/example_restauth') do
    all_files = Dir['{*,{app,config,db/migrate,lib,spec}/**/*}']
    sh_enscript ruby_files(all_files), 'ra-ex-ruby.ps', " -uEX -Eruby"
    sh_enscript text_files(all_files), 'ra-ex-text.ps', " -uEX "
  end
end


