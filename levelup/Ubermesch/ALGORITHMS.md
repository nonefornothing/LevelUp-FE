# Algorithms & Business Logic - Ubermensch App

## 🎯 Next Best Action Algorithm

### **Purpose**
Menentukan 1 aksi paling impactful yang harus dilakukan user hari ini berdasarkan:
- Domain dengan score terendah
- Goal yang stagnan
- Konteks hari ini (energi, waktu tersedia)
- Prioritas goal

### **Algorithm Pseudocode**

```kotlin
fun calculateNextBestAction(
    userId: String,
    currentDate: Date,
    userEnergy: Int?, // 1-5, dari check-in hari ini
    availableMinutes: Int? // waktu tersedia hari ini
): NextBestAction? {
    
    // 1. Get all active goals dengan progress < 100%
    val activeGoals = getActiveGoals(userId)
        .filter { it.progressPercentage < 100f }
    
    if (activeGoals.isEmpty()) return null
    
    // 2. Calculate domain scores
    val domainScores = calculateDomainScores(userId)
    
    // 3. Find underperforming domains (score < 60)
    val underperformingDomains = domainScores
        .filter { it.score < 60f }
        .sortedBy { it.score } // Lowest first
    
    // 4. Find stagnant goals (no progress in 7 days)
    val stagnantGoals = activeGoals
        .filter { goal ->
            val lastProgress = getLastProgressDate(goal.id)
            daysBetween(lastProgress, currentDate) >= 7
        }
    
    // 5. Score each goal berdasarkan multiple factors
    val goalScores = activeGoals.map { goal ->
        val domainScore = domainScores.first { it.domainId == goal.domainId }.score
        
        // Factor 1: Domain underperformance (0-40 points)
        val domainFactor = if (domainScore < 60) {
            40f * (1f - domainScore / 60f) // Lower score = higher factor
        } else {
            0f
        }
        
        // Factor 2: Stagnation (0-30 points)
        val stagnationFactor = if (stagnantGoals.contains(goal)) {
            30f
        } else {
            0f
        }
        
        // Factor 3: Deadline urgency (0-20 points)
        val urgencyFactor = goal.deadline?.let { deadline ->
            val daysUntilDeadline = daysBetween(currentDate, deadline)
            when {
                daysUntilDeadline < 7 -> 20f
                daysUntilDeadline < 14 -> 15f
                daysUntilDeadline < 30 -> 10f
                else -> 0f
            }
        } ?: 0f
        
        // Factor 4: Progress momentum (0-10 points)
        val momentumFactor = calculateMomentum(goal.id) // Recent progress rate
        
        val totalScore = domainFactor + stagnationFactor + urgencyFactor + momentumFactor
        
        GoalScore(goal, totalScore)
    }
    
    // 6. Select top priority goal
    val topGoal = goalScores.maxByOrNull { it.score }?.goal
        ?: return null
    
    // 7. Get available actions untuk goal ini
    val availableActions = getActionsForGoal(topGoal.id)
        .filter { !isCompletedToday(it.id, currentDate) }
    
    if (availableActions.isEmpty()) return null
    
    // 8. Filter actions berdasarkan konteks hari ini
    val contextualActions = availableActions.map { action ->
        // Adjust berdasarkan energi
        val energyMatch = when {
            userEnergy == null -> 1f
            userEnergy <= 2 -> {
                // Low energy: prefer quick actions (< 30 min)
                if (action.estimatedMinutes <= 30) 1f else 0.5f
            }
            userEnergy >= 4 -> {
                // High energy: prefer deep work (> 60 min)
                if (action.estimatedMinutes >= 60) 1f else 0.7f
            }
            else -> 1f
        }
        
        // Adjust berdasarkan waktu tersedia
        val timeMatch = availableMinutes?.let { available ->
            when {
                action.estimatedMinutes <= available -> 1f
                action.estimatedMinutes <= available * 1.5f -> 0.8f
                else -> 0.3f
            }
        } ?: 1f
        
        val contextualScore = energyMatch * timeMatch
        
        ActionScore(action, contextualScore)
    }
    
    // 9. Select best action
    val bestAction = contextualActions.maxByOrNull { it.score }?.action
        ?: availableActions.first()
    
    // 10. Generate recommendation message
    val recommendation = generateRecommendationMessage(
        goal = topGoal,
        action = bestAction,
        reason = when {
            underperformingDomains.any { it.domainId == topGoal.domainId } -> 
                "Domain ${topGoal.domainName} perlu perhatian"
            stagnantGoals.contains(topGoal) -> 
                "Goal ini belum ada progress 7 hari terakhir"
            else -> 
                "Aksi ini paling berdampak untuk goal kamu"
        }
    )
    
    return NextBestAction(
        actionId = bestAction.id,
        actionTitle = bestAction.title,
        goalId = topGoal.id,
        goalTitle = topGoal.title,
        estimatedMinutes = bestAction.estimatedMinutes,
        recommendation = recommendation,
        priority = goalScores.first { it.goal.id == topGoal.id }.score
    )
}

// Helper function: Calculate momentum
fun calculateMomentum(goalId: String): Float {
    val recentProgress = getProgressHistory(goalId, days = 7)
    if (recentProgress.size < 2) return 0f
    
    val progressRate = (recentProgress.last().progress - recentProgress.first().progress) / 7f
    // Normalize: 0-10 points
    return minOf(progressRate * 10f, 10f)
}
```

### **Implementation (Kotlin)**

```kotlin
data class NextBestAction(
    val actionId: String,
    val actionTitle: String,
    val goalId: String,
    val goalTitle: String,
    val estimatedMinutes: Int,
    val recommendation: String,
    val priority: Float
)

class NextBestActionUseCase(
    private val goalRepository: GoalRepository,
    private val actionRepository: ActionRepository,
    private val domainScoreRepository: DomainScoreRepository,
    private val checkInRepository: CheckInRepository
) {
    suspend fun execute(userId: String): NextBestAction? {
        val today = Date()
        val todayCheckIn = checkInRepository.getTodayCheckIn(userId)
        
        return calculateNextBestAction(
            userId = userId,
            currentDate = today,
            userEnergy = todayCheckIn?.energy,
            availableMinutes = estimateAvailableMinutes(todayCheckIn)
        )
    }
    
    private fun estimateAvailableMinutes(checkIn: CheckIn?): Int? {
        // Simple estimation based on time of day
        // Can be enhanced with calendar integration
        val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        return when {
            hour < 9 -> 120 // Morning: 2 hours
            hour < 17 -> 60 // Work hours: 1 hour
            hour < 21 -> 90 // Evening: 1.5 hours
            else -> 30 // Late: 30 min
        }
    }
}
```

---

## 📊 Domain Score Calculation Algorithm

### **Formula**

```
Domain Score = (Leading Indicators × 0.7) + (Lagging Indicators × 0.3)

Leading Indicators = Actions completion rate + Consistency
Lagging Indicators = Milestones completed + Outcome metrics
```

### **Implementation**

```kotlin
fun calculateDomainScore(
    userId: String,
    domainId: String,
    periodDays: Int = 7
): DomainScore {
    val endDate = Date()
    val startDate = Date(endDate.time - periodDays * 24 * 60 * 60 * 1000L)
    
    // Get all goals in this domain
    val goals = goalRepository.getGoalsByDomain(userId, domainId)
        .filter { it.status == "active" }
    
    if (goals.isEmpty()) {
        return DomainScore(
            domainId = domainId,
            score = 0f,
            leadingIndicators = emptyMap(),
            laggingIndicators = emptyMap()
        )
    }
    
    // Calculate Leading Indicators (70%)
    val totalActions = goals.flatMap { it.actions }
    val completedActions = actionRepository.getCompletedActions(
        userId = userId,
        actionIds = totalActions.map { it.id },
        startDate = startDate,
        endDate = endDate
    )
    
    val actionCompletionRate = if (totalActions.isNotEmpty()) {
        completedActions.size.toFloat() / totalActions.size
    } else {
        0f
    }
    
    // Consistency: check-in completion rate
    val checkIns = checkInRepository.getCheckIns(userId, startDate, endDate)
    val consistencyRate = checkIns.size.toFloat() / periodDays
    
    val leadingScore = (actionCompletionRate * 0.6f + consistencyRate * 0.4f) * 100f
    
    // Calculate Lagging Indicators (30%)
    val completedMilestones = goals.flatMap { it.milestones }
        .count { it.completedAt != null && it.completedAt >= startDate }
    val totalMilestones = goals.flatMap { it.milestones }.size
    
    val milestoneRate = if (totalMilestones > 0) {
        completedMilestones.toFloat() / totalMilestones
    } else {
        0f
    }
    
    // Outcome metrics: average progress of goals
    val avgProgress = goals.map { it.progressPercentage }.average().toFloat()
    
    val laggingScore = (milestoneRate * 0.5f + avgProgress / 100f * 0.5f) * 100f
    
    // Final score
    val finalScore = (leadingScore * 0.7f + laggingScore * 0.3f)
    
    return DomainScore(
        domainId = domainId,
        score = finalScore.coerceIn(0f, 100f),
        leadingIndicators = mapOf(
            "action_completion_rate" to actionCompletionRate,
            "consistency_rate" to consistencyRate
        ),
        laggingIndicators = mapOf(
            "milestone_rate" to milestoneRate,
            "avg_progress" to avgProgress
        ),
        calculatedAt = endDate
    )
}
```

---

## 🔄 Stagnation Detection Algorithm

### **Purpose**
Mendeteksi goal yang tidak ada progress dalam periode tertentu dan memberikan rekomendasi.

### **Implementation**

```kotlin
fun detectStagnation(
    userId: String,
    thresholdDays: Int = 7
): List<StagnationAlert> {
    val today = Date()
    val thresholdDate = Date(today.time - thresholdDays * 24 * 60 * 60 * 1000L)
    
    val activeGoals = goalRepository.getActiveGoals(userId)
    
    return activeGoals.mapNotNull { goal ->
        val lastProgress = getLastProgressDate(goal.id)
        
        if (lastProgress < thresholdDate) {
            val daysStagnant = daysBetween(lastProgress, today)
            
            // Analyze why stagnant
            val reasons = mutableListOf<String>()
            
            // Check if actions are too hard
            val actions = actionRepository.getActionsForGoal(goal.id)
            val avgEstimatedMinutes = actions.map { it.estimatedMinutes }.average()
            if (avgEstimatedMinutes > 120) {
                reasons.add("Actions mungkin terlalu besar")
            }
            
            // Check if no actions completed recently
            val recentCompletions = actionRepository.getCompletedActions(
                userId = userId,
                actionIds = actions.map { it.id },
                startDate = thresholdDate,
                endDate = today
            )
            if (recentCompletions.isEmpty()) {
                reasons.add("Tidak ada aksi yang diselesaikan")
            }
            
            // Check deadline pressure
            val deadlinePressure = goal.deadline?.let { deadline ->
                val daysUntilDeadline = daysBetween(today, deadline)
                daysUntilDeadline < 14 && daysUntilDeadline > 0
            } ?: false
            
            StagnationAlert(
                goalId = goal.id,
                goalTitle = goal.title,
                daysStagnant = daysStagnant,
                lastProgressDate = lastProgress,
                reasons = reasons,
                recommendations = generateStagnationRecommendations(
                    goal = goal,
                    reasons = reasons,
                    deadlinePressure = deadlinePressure
                )
            )
        } else {
            null
        }
    }
}

fun generateStagnationRecommendations(
    goal: Goal,
    reasons: List<String>,
    deadlinePressure: Boolean
): List<String> {
    val recommendations = mutableListOf<String>()
    
    if (reasons.contains("Actions mungkin terlalu besar")) {
        recommendations.add("Pecah aksi menjadi langkah lebih kecil (5-15 menit)")
    }
    
    if (reasons.contains("Tidak ada aksi yang diselesaikan")) {
        recommendations.add("Pilih 1 aksi minimum untuk dilakukan hari ini")
    }
    
    if (deadlinePressure) {
        recommendations.add("Fokus pada milestone terdekat")
        recommendations.add("Pertimbangkan extend deadline jika realistis")
    }
    
    if (recommendations.isEmpty()) {
        recommendations.add("Coba lakukan 1 aksi kecil untuk membangun momentum")
    }
    
    return recommendations
}
```

---

## ⚖️ Life Portfolio Rebalancing Algorithm

### **Purpose**
Mendeteksi domain yang under-invested dan menyarankan rebalancing effort.

### **Implementation**

```kotlin
fun calculateRebalancingRecommendation(
    userId: String,
    periodDays: Int = 7
): RebalancingRecommendation? {
    val domains = domainRepository.getDomains(userId)
    val targetAllocations = domains.associate { it.id to it.targetAllocation }
    
    // Calculate actual effort allocation
    val actualAllocations = calculateActualAllocations(userId, domains, periodDays)
    
    // Find domains dengan deviation > 10%
    val deviations = domains.map { domain ->
        val target = targetAllocations[domain.id] ?: 0f
        val actual = actualAllocations[domain.id] ?: 0f
        val deviation = actual - target
        
        DomainDeviation(
            domainId = domain.id,
            domainName = domain.name,
            targetAllocation = target,
            actualAllocation = actual,
            deviation = deviation
        )
    }
    
    val significantDeviations = deviations.filter { abs(it.deviation) > 10f }
    
    if (significantDeviations.isEmpty()) {
        return null
    }
    
    val underInvested = significantDeviations
        .filter { it.deviation < -10f }
        .sortedBy { it.deviation } // Most under-invested first
    
    val overInvested = significantDeviations
        .filter { it.deviation > 10f }
        .sortedByDescending { it.deviation } // Most over-invested first
    
    // Generate rebalancing plan
    val rebalancingActions = mutableListOf<RebalancingAction>()
    
    underInvested.forEach { domain ->
        rebalancingActions.add(
            RebalancingAction(
                domainId = domain.domainId,
                domainName = domain.domainName,
                action = "Increase",
                currentAllocation = domain.actualAllocation,
                targetAllocation = domain.targetAllocation,
                suggestedActions = generateRebalancingActions(domain.domainId, userId)
            )
        )
    }
    
    return RebalancingRecommendation(
        deviations = deviations,
        underInvestedDomains = underInvested,
        overInvestedDomains = overInvested,
        rebalancingActions = rebalancingActions,
        nextWeekPlan = generateNextWeekPlan(rebalancingActions)
    )
}

fun calculateActualAllocations(
    userId: String,
    domains: List<Domain>,
    periodDays: Int
): Map<String, Float> {
    val endDate = Date()
    val startDate = Date(endDate.time - periodDays * 24 * 60 * 60 * 1000L)
    
    // Calculate total effort (in minutes) per domain
    val domainEfforts = domains.associate { domain ->
        val goals = goalRepository.getGoalsByDomain(userId, domain.id)
        val actions = goals.flatMap { it.actions }
        val completions = actionRepository.getCompletedActions(
            userId = userId,
            actionIds = actions.map { it.id },
            startDate = startDate,
            endDate = endDate
        )
        
        val totalMinutes = completions.sumOf { it.durationMinutes ?: it.action.estimatedMinutes }
        
        domain.id to totalMinutes.toFloat()
    }
    
    val totalEffort = domainEfforts.values.sum()
    
    // Convert to percentages
    return if (totalEffort > 0) {
        domainEfforts.mapValues { (it.value / totalEffort) * 100f }
    } else {
        domainEfforts.mapValues { 0f }
    }
}
```

---

## 🧪 N-of-1 Experiment Tracking

### **Algorithm untuk Experiment Results**

```kotlin
fun analyzeExperimentResults(
    experimentId: String
): ExperimentAnalysis {
    val experiment = experimentRepository.getExperiment(experimentId)
    val baselineData = getBaselineData(experiment)
    val interventionData = getInterventionData(experiment)
    
    // Calculate before/after metrics
    val baselineAvg = baselineData.map { it.metricValue }.average()
    val interventionAvg = interventionData.map { it.metricValue }.average()
    
    val change = interventionAvg - baselineAvg
    val changePercent = (change / baselineAvg) * 100f
    
    // Simple statistical test (t-test approximation)
    val isSignificant = isStatisticallySignificant(
        baselineData = baselineData,
        interventionData = interventionData
    )
    
    return ExperimentAnalysis(
        experimentId = experimentId,
        baselineAverage = baselineAvg,
        interventionAverage = interventionAvg,
        change = change,
        changePercent = changePercent,
        isSignificant = isSignificant,
        recommendation = generateExperimentRecommendation(
            change = change,
            isSignificant = isSignificant,
            hypothesis = experiment.hypothesis
        )
    )
}

fun isStatisticallySignificant(
    baselineData: List<MetricDataPoint>,
    interventionData: List<MetricDataPoint>,
    alpha: Float = 0.05f
): Boolean {
    // Simplified: check if difference is > 2 standard deviations
    val baselineStdDev = calculateStandardDeviation(baselineData.map { it.metricValue })
    val interventionStdDev = calculateStandardDeviation(interventionData.map { it.metricValue })
    
    val pooledStdDev = sqrt((baselineStdDev * baselineStdDev + interventionStdDev * interventionStdDev) / 2)
    val difference = interventionData.map { it.metricValue }.average() - 
                     baselineData.map { it.metricValue }.average()
    
    val zScore = difference / pooledStdDev
    
    return abs(zScore) > 1.96 // 95% confidence
}
```

---

## 📈 Progress Calculation (60% Actions + 30% Milestones + 10% Outcome)

```kotlin
fun calculateGoalProgress(goalId: String): Float {
    val goal = goalRepository.getGoal(goalId)
    val actions = actionRepository.getActionsForGoal(goalId)
    val milestones = goal.milestones
    
    // 60% dari actions completion
    val totalActions = actions.size
    val completedActions = actions.count { action ->
        actionRepository.isCompletedToday(action.id)
    }
    val actionProgress = if (totalActions > 0) {
        (completedActions.toFloat() / totalActions) * 60f
    } else {
        0f
    }
    
    // 30% dari milestones
    val totalMilestones = milestones.size
    val completedMilestones = milestones.count { it.completedAt != null }
    val milestoneProgress = if (totalMilestones > 0) {
        (completedMilestones.toFloat() / totalMilestones) * 30f
    } else {
        0f
    }
    
    // 10% dari outcome metric
    val outcomeProgress = calculateOutcomeMetricProgress(goal) * 10f
    
    return (actionProgress + milestoneProgress + outcomeProgress).coerceIn(0f, 100f)
}

fun calculateOutcomeMetricProgress(goal: Goal): Float {
    val metric = goal.outcomeMetric ?: return 0f
    
    return when (metric.type) {
        "number" -> {
            val current = metric.currentValue ?: 0f
            val target = metric.targetValue ?: 1f
            (current / target).coerceIn(0f, 1f)
        }
        "percentage" -> {
            metric.currentValue ?: 0f
        }
        else -> 0f
    }
}
```

---

## 🔄 Conflict Resolution (Sync)

```kotlin
fun resolveConflict(
    localEntity: Entity,
    remoteEntity: Entity
): Entity {
    // Strategy: Last Write Wins dengan merge untuk arrays
    
    return when {
        // Remote lebih baru
        remoteEntity.updatedAt > localEntity.updatedAt -> {
            // Merge arrays (evidence, tags, etc.)
            mergeArrays(localEntity, remoteEntity)
        }
        // Local lebih baru
        localEntity.updatedAt > remoteEntity.updatedAt -> {
            mergeArrays(remoteEntity, localEntity)
        }
        // Same timestamp: merge both
        else -> {
            mergeBoth(localEntity, remoteEntity)
        }
    }
}

fun mergeArrays(local: Entity, remote: Entity): Entity {
    // Combine arrays, remove duplicates
    val mergedEvidence = (local.evidenceUrls + remote.evidenceUrls).distinct()
    val mergedTags = (local.tags + remote.tags).distinct()
    
    return local.copy(
        evidenceUrls = mergedEvidence,
        tags = mergedTags,
        updatedAt = maxOf(local.updatedAt, remote.updatedAt)
    )
}
```

---

**Note**: Semua algoritma ini adalah versi simplified. Untuk production, perlu:
- Error handling yang lebih robust
- Edge case handling
- Performance optimization (caching, indexing)
- Unit tests untuk setiap algoritma

