function(key, values, rereduce) {
	var returnObject = new Object();
	returnObject.nofDocs = 0;
	returnObject.nofCompleted = 0;
	for(var i = 0; i < values.length; i++) {
		if(key === null)
			returnObject.nofDocs += values[i].nofDocs;
		else
			returnObject.nofDocs++;
		if(values[i])
			if(key === null)
				returnObject.nofCompleted += values[i].nofCompleted;
			else
				returnObject.nofCompleted++;
	}
	return returnObject;
}