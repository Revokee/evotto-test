require 'optparse'
require 'sqlite3'
require 'csv'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: app.rb [options]"

  opts.on('-s', '--source /path/to/file/file.csv', 'Source file name with path.') { |v| options[:source] = v }
  opts.on('-t', '--total Age,ProjectCount,TotalValue', 'Sum Column Total') { |v| options[:total] = v }
  opts.on('-f', '--find NAME', 'Find Record with the given name (exact match).') { |v| options[:find] = v }
  opts.on('-o', '--order_by [age|project_count|total_value,asc|desc]', 'Optional Parameter: Order by Age, ProjectCount or TotalValue; Descending or Ascending.') { |v| options[:order_by] = v }
  opts.on('-h', '--help', 'Prints this help') {puts opts}
end.parse!

def header
	puts "Name | Age | ProjectCount | TotalValue"
end


if options[:source]
	begin
		csv_text = File.read(options[:source])
		csv = CSV.parse(csv_text, :headers => true,:skip_blanks=>true)

		DBNAME = "app.sqlite"
		File.delete(DBNAME) if File.exists?DBNAME

		db = SQLite3::Database.new 'app.sqlite'

		rows = db.execute <<-SQL 
          create table data(
           name varchar(256),
           age int,
           project_count int,
           total_value int
         );
        SQL

		csv.each do |row|
		  db.execute("INSERT INTO data (name, age, project_count, total_value)
		VALUES (?,?,?,?)", [row[0], row[1], row[2], row[3]])
		end

		case options
		when -> (h) { !h[:find].nil? }
			header
			db.execute 'select * from data where name = "' + options[:find] + '" ' do |row|
			  puts row.join(' | ')
			end
		when -> (h) { !h[:order_by].nil? }
			case options[:order_by]
			when "age,desc"
				header
				db.execute 'select * from data order by age desc' do |row|
			  		puts row.join(' | ')
				end
			when "age,asc"
				header
				db.execute 'select * from data order by age asc' do |row|
			  		puts row.join(' | ')
				end
			when "project_count,desc"
				header
				db.execute 'select * from data order by project_count desc' do |row|
			  		puts row.join(' | ')
				end
			when "project_count,asc"
				header
				db.execute 'select * from data order by project_count asc' do |row|
			  		puts row.join(' | ')
				end
			when "total_value,desc"
				header
				db.execute 'select * from data order by total_value desc' do |row|
			  		puts row.join(' | ')
				end
			when "total_value,asc"
				header
				db.execute 'select * from data order by total_value asc' do |row|
			  		puts row.join(' | ')
				end
			else
				puts "Wrong order_by usage. Specify the column and the method. Eg.: age,desc"
			end
		when -> (h) { !h[:total].nil? }
			if options[:total] == "Age"
				db.execute 'select sum(age) from data' do |row|
					puts "Age: " + row[0].to_s
				end
			elsif options[:total] == "ProjectCount"
				db.execute 'select sum(project_count) from data' do |row|
					puts "ProjectCount: " + row[0].to_s
				end
			elsif options[:total] == "TotalValue"
				db.execute 'select sum(total_value) from data' do |row|
					puts "TotalValue: " + row[0].to_s
				end
			else
				puts "Invalid column"
			end
		else
			header
			db.execute 'select * from data' do |row|
			  puts row.join(' | ')
			end
		end

		File.delete(DBNAME) if File.exists?DBNAME

	rescue Errno::ENOENT
		puts "Couldn't find file" + options[:source]
	end
else

end
