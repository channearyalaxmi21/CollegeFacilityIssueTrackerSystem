trigger CaseTrigger on Case (before insert, before update) {

    // Define Queue Ids (replace with your actual Queue IDs after setup)
    Id electricalQueueId   = '00Gg5000000Lp17';
    Id plumbingQueueId     = '00Gg5000000Lp7Z';
    Id itQueueId           = '00Gg5000000Hf2r';
    Id defaultQueueId      = '00Gg5000000Lp9B'; // fallback queue

    for (Case c : Trigger.new) {
        
        // --- 1. Auto-assign Case Owner (Queue) based on Category ---
        if (Trigger.isInsert || (Trigger.isUpdate && c.Category__c != Trigger.oldMap.get(c.Id).Category__c)) {
            if (c.Category__c == 'Electrical') {
                c.OwnerId = electricalQueueId;
            } else if (c.Category__c == 'Plumbing') {
                c.OwnerId = plumbingQueueId;
            } else if (c.Category__c == 'IT Equipment') {
                c.OwnerId = itQueueId;
            } else {
                c.OwnerId = defaultQueueId;
            }
        }

        // --- 2. Set SLA Deadline based on Issue Severity ---
        if (String.isNotBlank(c.Issue_Severity__c)) {
            Integer hoursToAdd = 0;
            switch on c.Issue_Severity__c {
                when 'Low'      { hoursToAdd = 72; }   // 3 days
                when 'Medium'   { hoursToAdd = 48; }   // 2 days
                when 'High'     { hoursToAdd = 24; }   // 1 day
                when 'Critical' { hoursToAdd = 12; }   // 12 hours
                when else       { hoursToAdd = 24; }
            }
            c.SLA_Deadline__c = System.now().addHours(hoursToAdd);
        }

        // --- 3. Flag costly repairs for approval ---
        if (c.Estimated_Cost__c != null && c.Estimated_Cost__c > 50000) {
            c.Requires_Approval__c = true;
        } else {
            c.Requires_Approval__c = false;
        }
    }
}