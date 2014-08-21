function(doc) {
    switch(doc.type) {
        case 'regular_meals':
        case 'physical_activity':
        case 'regular_sleep':
        case 'emotion_awareness':
        case 'agoraphobia':
            emit(doc.beginDate, doc);
            break;
        default:
            break;
    }
}