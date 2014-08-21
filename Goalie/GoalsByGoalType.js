function(doc) {
    if(doc.type == 'Goal') {
        emit(doc.goalType, doc);
    }
}