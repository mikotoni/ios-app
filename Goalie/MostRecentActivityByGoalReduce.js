function(key, values, rereduce) {
	var bestDate = null;
	for(var i = 0; i < values.length; i++) {
		if(values[i] === null) ;
		else {
			if(bestDate === null)
				bestDate = values[i];
			else {
				var curDateObj = new Date(values[i]);
				var bestDateObj = new Date(bestDate);
				if(curDateObj.getTime() > bestDateObj.getTime())
					bestDate = values[i];
			}
		}
	}
	return bestDate;
}