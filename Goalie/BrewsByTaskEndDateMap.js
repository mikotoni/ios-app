function(doc) {
    if(doc.type == 'TaskBrew') {
        emit([doc.task, doc.endDate], beginDate);
    }
}