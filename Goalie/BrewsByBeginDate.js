function(doc) {
    if(doc.type == 'TaskBrew') {
        emit([doc.beginDate]);
    }
}