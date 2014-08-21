function(doc) {
    if(doc.type == 'ActiveTask') {
        //emit([doc.activeGoal, doc.task, doc.occurrenceIndex], doc);
        emit([doc.activeGoal, doc.task], doc);
    }
}