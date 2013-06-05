@isTest
private without sharing class TestSObjectDescribe {
	
	@isTest //Tests all forms of the getDescribe static
	static void getAccountDescribes(){
		SObjectDescribe d = SObjectDescribe.getDescribe('Account');
		SObjectDescribe d2 = SObjectDescribe.getDescribe(Account.SObjectType);
		SObjectDescribe d3 = SObjectDescribe.getDescribe(Schema.SObjectType.Account);
		System.assertEquals('Account', d.getDescribe().getName());
		System.assert( (d === d2 && d2 === d3) ,'All three getDescribe calls should return the same cached instance.');
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

	@isTest
	static void simpleAccountFieldSetDescribe(){ 
		SObjectDescribe d = SObjectDescribe.getDescribe(Account.SObjectType);
		Map<String,Schema.FieldSet> fields;
		for(integer i = 0; i < 10; i++){
			fields = d.getFieldSetsMap();
		}
		System.assertEquals(1, Limits.getFieldSetsDescribes() );
		//no asserts on result size to avoid a requirement on field sets existing
	}

	@isTest
	static void flushCache(){
		SObjectDescribe d = SObjectDescribe.getDescribe('Account');
		SObjectDescribe.flushCache();
		SObjectDescribe d2 = SObjectDescribe.getDescribe('Account');
		System.assert(d !== d2, 'Second object should be a fresh instance after a cache flush.' );
	}

	@isTest
	static void rawGlobalDescribeCheck(){
		Map<String,Schema.SObjectType> systemGd = Schema.getGlobalDescribe();
		Map<String,Schema.SObjectType> cachedGd = SObjectDescribe.getRawGlobalDescribe();
		System.assertEquals(systemGd.size(),cachedGd.size());
	}

}
