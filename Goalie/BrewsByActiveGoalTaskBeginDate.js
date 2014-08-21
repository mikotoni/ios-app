function(doc) {
    if(doc.type == 'TaskBrew') {
        emit([doc.activeGoal, doc.task, doc.beginDate], doc);
    }
}