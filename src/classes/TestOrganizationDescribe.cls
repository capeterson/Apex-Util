@isTest
private without sharing class TestOrganizationDescribe {
	@isTest
	static void chatterEnabled(){
		boolean chatterEnabled = OrganizationDescribe.getInstance().isChatterEnabled();
		System.assertEquals(
			Schema.SObjectType.User.isFeedEnabled(),
			chatterEnabled
		);
	}

	@isTest
	static void advancedMultiCurrency(){
		boolean isACM = OrganizationDescribe.getInstance().isAdvancedMultiCurrency();
		System.assertEquals(
			SObjectDescribe.getDescribe('DatedConversionRate') != null,
			isACM
		);
	}

	@isTest
	static void packageInstalled(){
		boolean isFakePKgInstalled = OrganizationDescribe.getInstance().isManagedPackageInstalled('fe1477f'); //a dummy managed package that won't ever be installed
		System.assertEquals(false,isFakePKgInstalled);
	}
}
