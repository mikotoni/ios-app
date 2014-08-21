function(doc) {
    if(doc.type == 'Goal')
        emit(doc._id, doc);
};