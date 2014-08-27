function(doc) {
    if(doc.type == 'ActiveTask') {
        emit([doc.activeGoal, doc.task, doc.beginDate], doc);
    }
}