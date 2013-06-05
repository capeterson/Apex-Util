@isTest
private without sharing class TestSObjectDescribe {
	
	@isTest
	static void simpleAccountDescribe(){
		SObjectDescribe d = SObjectDescribe.getDescribe('Account');
		System.assertEquals('Account', d.getDescribe().getName());
	}

	@isTest
	static void simpleAccountFieldDescribe(){
		SObjectDescribe d = SObjectDescribe.getDescribe(Account.SObjectType);
		Map<String,Schema.SObjectField> fields;
		for(integer i = 0; i < 10; i++){
			fields = d.getFieldsMap();
		}
		System.assertEquals(1, Limits.getFieldsDescribes() );
		System.assertEquals(false,fields.isEmpty());
	}

}
