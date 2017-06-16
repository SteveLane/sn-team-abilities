d3.json('data/sn-games.json', function (error, data) {
    
    function tabulate(data, columns, team, round) {
	var table = d3.select('body').select('#test-table').append('table')
	var thead = table.append('thead')
	var tbody = table.append('tbody');

	// Filter by team/round
	function filterJSON(data, team, round) {
	    var result;
	    for (var teamIndex in data) {
		if (teamIndex === team) {
		    result = data[teamIndex][round];
		}
	    }
	    console.log(result);
	    return result;
	}

	var selectedTable = filterJSON(data, team, round);
	
	// append the header row
	thead.append('tr')
	    .selectAll('th')
	    .data(columns).enter()
	    .append('th')
	    .text(function (column) { return column; });
	
	// create a row for each object in the data
	var rows = tbody.selectAll('tr')
	    .data(selectedTable)
	    .enter()
	    .append('tr');
	
	// create a cell in each row for each column
	var cells = rows.selectAll('td')
	    .data(function (row) {
		return columns.map(function (column) {
		    return {column: column, value: row[column]};
		});
	    })
	    .enter()
	    .append('td')
	    .text(function (d) { return d.value; });
	
	return table;
    }
    
    // render the table(s)
    tabulate(data, ['Team', 'Q1', 'Q2', 'Q3', 'Q4', 'Score'], "Adelaide Thunderbirds", 7);

});
