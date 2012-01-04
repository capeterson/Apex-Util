@isTest
private class RecordTypeDescribe_test {
	static testmethod void constructor(){
		RecordType rt = [SELECT id, name, description, developerName, namespacePrefix, sObjectType, isActive 
			FROM RecordType WHERE sObjectType = 'itil_b__Incident__c' LIMIT 1];
		Schema.RecordTypeInfo rti = 
			itil_b__Incident__c.SObjectType.getDescribe().getRecordTypeInfosById().get(rt.id);
		
		RecordTypeDescribe rtd = new RecordTypeDescribe(rt,rti);
		
		System.assertEquals(rti.getName(), rtd.label,'Describe label doesn\t match');
		System.assertEquals(rt.id, rtd.recordTypeId); 
	}
	
	static testmethod void constructor_differentTypes(){
		Exception e;
		try{
			RecordType rt = [SELECT id, name FROM RecordType WHERE sObjectType = 'Contact' LIMIT 1];
			RecordTypeInfo rti = Schema.sObjectType.itil_b__Incident__c.getRecordTypeInfos().get(0);
			RecordTypeDescribe rtd = new RecordTypeDescribe(rt,rti);
		}catch(Exceptions.ArgumentException ex){
			e = ex;
		}
		System.assertNotEquals(null,e,'Failed to throw an exception for mismatched object types!');
	}
	
	static testmethod void constructor_nullOption(){
		Exception e;
		try{
			RecordType rt = [SELECT id, name FROM RecordType WHERE sObjectType = 'Contact' LIMIT 1];
			RecordTypeInfo rti = Schema.sObjectType.itil_b__Incident__c.getRecordTypeInfos().get(0);
			RecordTypeDescribe rtd = new RecordTypeDescribe(rt,null);
		}catch(Exceptions.ArgumentException ex){
			e = ex;
		}
		System.assertNotEquals(null,e,'Failed to throw an exception for null recordTypeInfo parameter');
	}
	
	static testmethod void getDefault(){
		itil_b__Incident__c inc = new itil_b__Incident__c();
		insert inc;
		inc = [SELECT id, RecordTypeId FROM itil_b__Incident__c WHERE id = :inc.id];
		
		RecordTypeDescribe defaultRT = RecordTypeDescribe.getDefault(Schema.itil_b__Incident__c.sObjectType);
		System.assertNotEquals(null,defaultRt,'Couldn\'t find a default record type for Incident.');
		if(inc.recordTypeId != null)
			System.assertEquals(inc.recordTypeId,defaultRT.recordTypeId,'Default record type didn\'t match.');
		else
			System.assertEquals(null,defaultRt,'Record type was master - expected back a null recordTypeDescribe.');
	}
	
	static testmethod void getAvailable(){
		Set<id> availableIds = new Set<id>();
		for(Schema.RecordTypeInfo rti:Schema.sObjectType.itil_b__Incident__c.getRecordTypeInfos()){
			if(rti.isAvailable())
				availableIds.add(rti.getRecordTypeId());
		}
		availableIds.remove( '012000000000000AAA' ); //see http://www.ca-peterson.com/2011/11/master-record-types-id.html
		
		Map<id,RecordTypeDescribe> rtds = RecordTypeDescribe.getAvailable( Schema.sObjectType.itil_b__Incident__c.getSObjectType() );
		System.assertEquals(availableIds.size(),rtds.size(),'Number of returned record types didn\'t match!');
		
		for(Id recordTypeId:availableIds)
			System.assert(rtds.containsKey(recordTypeId), 'Failed to locate available record type in RecordTypeDescribe output: '+recordTypeId);
	}
	
	static testmethod void getActive(){
		Set<id> availableIds = new Set<id>();
		for(RecordType rt:[SELECT id FROM RecordType WHERE sObjectType = 'itil_b__Incident__c' AND isActive = true])
				availableIds.add(rt.id);
		
		Map<id,RecordTypeDescribe> rtds = RecordTypeDescribe.getActive( Schema.sObjectType.itil_b__Incident__c.getSObjectType() );
		System.assertEquals(availableIds.size(),rtds.size(),'Number of returned record types didn\'t match!');
		
		for(Id recordTypeId:availableIds)
			System.assert(rtds.containsKey(recordTypeId), 'Failed to locate available record type in RecordTypeDescribe output: '+recordTypeId);
	}
}