function(doc) {
    switch(doc.type) {
        case 'ShootPhotoTask':
        case 'SliderTask':
        case 'SwitchTask':
        case 'DescriptiveTask':
        case 'MealTask':
        case 'MoodTask':
        case 'MotionTask':
        case 'VisitTask':
        case 'SleepTask':
            emit(doc._id, doc);
            break;
        default:
            break;
    }
}