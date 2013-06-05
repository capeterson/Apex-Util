@isTest
private class TestRecordTypeDescribe {
	@isTest
	static void constructor(){
		RecordType rt = [SELECT id, name, description, developerName, namespacePrefix, sObjectType, isActive 
			FROM RecordType WHERE sObjectType = 'Test_Object__c' LIMIT 1];
		Schema.RecordTypeInfo rti = 
			Test_Object__c.SObjectType.getDescribe().getRecordTypeInfosById().get(rt.id);
		
		RecordTypeDescribe rtd = new RecordTypeDescribe(rt,rti);
		
		System.assertEquals(rti.getName(), rtd.label,'Describe label doesn\t match');
		System.assertEquals(rt.id, rtd.recordTypeId); 
	}
	
	@isTest
	static void constructor_differentTypes(){
		Exception e;
		try{
			RecordType rt = (RecordType) JSON.deserialize('{"id": "012000000000999AAA", "name": "default", "developerName": "default", "namespacePrefix": null, "description": null, "sObjectType": "Contact", "isActive": true}',RecordType.class);//[SELECT id, name, developerName, namespacePrefix, description, sObjectType, isActive FROM RecordType WHERE sObjectType = 'Contact' LIMIT 1];
			RecordTypeInfo rti = Schema.sObjectType.Test_Object__c.getRecordTypeInfos().get(0);
			RecordTypeDescribe rtd = new RecordTypeDescribe(rt,rti);
		}catch(RecordTypeDescribe.ArgumentException ex){
			e = ex;
		}
		System.assertNotEquals(null,e,'Failed to throw an exception for mismatched object types!');
	}
	
	@isTest
	static void constructor_nullOption(){
		Exception e;
		try{
			RecordType rt = [SELECT id, name FROM RecordType WHERE sObjectType = 'Test_Object__c' LIMIT 1];
			RecordTypeInfo rti = Schema.sObjectType.Test_Object__c.getRecordTypeInfos().get(0);
			RecordTypeDescribe rtd = new RecordTypeDescribe(rt,null);
		}catch(RecordTypeDescribe.ArgumentException ex){
			e = ex;
		}
		System.assertNotEquals(null,e,'Failed to throw an exception for null recordTypeInfo parameter');
	}
	
	@isTest
	static void getDefault(){
		Test_Object__c inc = new Test_Object__c();
		insert inc;
		inc = [SELECT id, RecordTypeId FROM Test_Object__c WHERE id = :inc.id];
		
		RecordTypeDescribe defaultRT = RecordTypeDescribe.getDefault(Schema.Test_Object__c.sObjectType);
		System.assertNotEquals(null,defaultRt,'Couldn\'t find a default record type for Incident.');
		if(inc.recordTypeId != null)
			System.assertEquals(inc.recordTypeId,defaultRT.recordTypeId,'Default record type didn\'t match.');
		else
			System.assertEquals(null,defaultRt,'Record type was master - expected back a null recordTypeDescribe.');
	}
	
	@isTest
	static void getAvailable(){
		Set<id> availableIds = new Set<id>();
		for(Schema.RecordTypeInfo rti:Schema.sObjectType.Test_Object__c.getRecordTypeInfos()){
			if(rti.isAvailable())
				availableIds.add(rti.getRecordTypeId());
		}
		availableIds.remove( '012000000000000AAA' ); //see http://www.ca-peterson.com/2011/11/master-record-types-id.html
		
		Map<id,RecordTypeDescribe> rtds = RecordTypeDescribe.getAvailable( Schema.sObjectType.Test_Object__c.getSObjectType() );
		System.assertEquals(availableIds.size(),rtds.size(),'Number of returned record types didn\'t match!');
		
		for(Id recordTypeId:availableIds)
			System.assert(rtds.containsKey(recordTypeId), 'Failed to locate available record type in RecordTypeDescribe output: '+recordTypeId);
	}
	
	@isTest
	static void getActive(){
		Set<id> availableIds = new Set<id>();
		for(RecordType rt:[SELECT id FROM RecordType WHERE sObjectType = 'Test_Object__c' AND isActive = true])
				availableIds.add(rt.id);
		
		Map<id,RecordTypeDescribe> rtds = RecordTypeDescribe.getActive( Schema.sObjectType.Test_Object__c.getSObjectType() );
		System.assertEquals(availableIds.size(),rtds.size(),'Number of returned record types didn\'t match!');
		
		for(Id recordTypeId:availableIds)
			System.assert(rtds.containsKey(recordTypeId), 'Failed to locate available record type in RecordTypeDescribe output: '+recordTypeId);
	}
}