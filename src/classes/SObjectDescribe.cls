public with sharing class SObjectDescribe {
	public static SObjectDescribe getDescribe(String sObjectName){return null;}
	public static SObjectDescribe getDescribe(String sObjectName,String preferredNamespace){return null;}
	public static SObjectDescribe getDescribe(String sObjectName,List<String> preferredNamespaces){return null;}
	public static SObjectDescribe getDescribe(Schema.SObjectType SObjectType){return null;}
	public static SObjectDescribe getDescribe(Schema.DescribeSObjectResult nativeDescribe){return null;}

	public static Map<String,SObjectDescribe> getGlobalDescribe(){return null;}
	//returns the same results as the native method, just with caching built in to avoid limits
	public static Map<String,SObjectType> getRawGlobalDescribe(){return null;}

	public static List<SObjectDescribe> getChatterEnabled(){return null;}
	public static List<SObjectDescribe> getSharingEnabled(){return null;}
	public static List<SObjectDescribe> getFieldTrackingEnabled(){return null;}
}
