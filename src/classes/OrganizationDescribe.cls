/**
 * This class is a singleton to comply with the style of the other describe objects.
 * Declared as without sharing to avoid false negatives in low-priviledge execution contexts,
 * e.g. isAdvancedMultiCurrency would return false even if it was for customer portal users.
 * This should not be a security issue as no data can be written via this class and the data accessed in very generic.
**/
public without sharing class OrganizationDescribe {
	private static OrganizationDescribe instance;
	private OrganizationDescribe(){}

	public static OrganizationDescribe getInstance(){
		if(instance == null)
			instance = new OrganizationDescribe();
		return instance;
	}

	//In all situations where chatter is enabled for the org user is feed enabled for user profiles.
	public  boolean isChatterEnabled(){
		return Schema.SObjectType.User.isFeedEnabled();
	}
	//DatedConversionRate type is only valid for advanced MC orgs
	public static boolean isAdvancedMultiCurrency(){
		if(UserInfo.isMultiCurrencyOrganization() && SObjectDescribe.getDescribe('DatedConversionRate') != null)
			return true;
		return false;
	}
}
