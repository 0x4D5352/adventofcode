def main [path part] {
	let left = open $path | from ssv --noheaders | get column0 | sort | wrap first
	let right = open $path |from ssv --noheaders | get column1 | sort | wrap second
	let right_count = $right | polars into-df | polars value-counts | polars sort-by second
	match $part { 
		1 => ($left | merge $right | upsert difference {|row| ($row.first | into int) - ($row.second | into int) | math abs} | get difference | math sum),
		2 => ($left | upsert similarity {|row| if ($right_count | polars into-nu | where second  == $row.first | is-not-empty  ) {($row.first | into int) * ($right_count | polars into-nu | where second == $row.first | get count.0)} else {0} } | get similarity | math sum),
		_ => "you forgot to select a part"
	}
}
