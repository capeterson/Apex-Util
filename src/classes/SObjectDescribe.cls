public with sharing class SObjectDescribe {
	//internal implementation details
	private Schema.SObjectType token;
	private Schema.DescribeSObjectResult describe { //lazy load - keep this leightweight until we need more data
		get{
			if(describe == null)
				describe = token.getDescribe();
			return describe;
		}
		set;
	}
	private Map<String,Schema.SObjectField> fields {
		get{
			if(fields == null)
				fields = describe.fields.getMap();
			return fields;
		}
		set;
	}
	private Map<String,Schema.FieldSet> fieldSets {
		get{
			if(fieldSets == null)
				fieldSets = describe.fieldSets.getMap();
			return fieldSets;
		}
		set;
	}
	private SObjectDescribe(Schema.SObjectType token){
		if(globalDescribe.containsKey( String.valueOf(token) ))
			throw new DuplicateDescribeException(token + ' is already in the describe cache');
		this.token = token;
		globalDescribe.put( String.valueOf(token).toLowerCase() , this);
	}

	//public instace methods
	public Schema.DescribeSObjectResult getDescribe(){
		return describe;
	}
	public Map<String,Schema.SObjectField> getFieldsMap(){
		return fields;
	}
	public Map<String,Schema.FieldSet> getFieldSetsMap(){
		return fieldSets;
	}



	private static Map<String,Schema.SObjectType> rawGlobalDescribe {
		get{
			if(rawGlobalDescribe == null)
				rawGlobalDescribe = Schema.getGlobalDescribe();
			return rawGlobalDescribe;
		}
		set;
	}
	private static Map<String,SObjectDescribe> globalDescribe {get{
			if(globalDescribe == null)
				globalDescribe = new Map<String,SObjectDescribe>();
			return globalDescribe;
		} 
		set;
	}
	public static SObjectDescribe getDescribe(String sObjectName){
		SObjectDescribe result = globalDescribe.get(sObjectName.toLowerCase());
		if(result == null){
			Schema.SObjectType token = rawGlobalDescribe.get(sObjectName.toLowerCase());
			result = new SObjectDescribe(token);
		}
		return result;
	}
	public static SObjectDescribe getDescribe(Schema.SObjectType token){
		SObjectDescribe result = globalDescribe.get(String.valueOf(token).toLowerCase());
		if(result == null)
			result = new SObjectDescribe(token);		
		return result;
	}
	public static SObjectDescribe getDescribe(Schema.DescribeSObjectResult nativeDescribe){
		SObjectDescribe result = globalDescribe.get(nativeDescribe.getName().toLowerCase());
		if(result == null)
			result = new SObjectDescribe(nativeDescribe.getSobjectType());		
		return result;
	}

	//returns the same results as the native method, just with caching built in to avoid limits
	public static Map<String,SObjectType> getRawGlobalDescribe(){
		return rawGlobalDescribe;
	}

	public class DuplicateDescribeException extends Exception{}
}
