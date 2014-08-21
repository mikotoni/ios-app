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
            emit(doc.goalId, doc.completedString);
            break;
        default:
            break;
    }
}