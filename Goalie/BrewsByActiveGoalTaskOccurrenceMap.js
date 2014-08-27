function(doc) {
    if(doc.type == 'TaskBrew') {
        //emit([doc.activeGoal, doc.task, doc.occurrenceIndex], doc);
        emit([doc.activeGoal, doc.task], doc);
    }
}