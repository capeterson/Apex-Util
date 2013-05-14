/**
 * Simple wrapper class to represent a record type sObject and RecordTypeInfo object all in one.
 * This object needs to be used in any ui-facing record type operations going forward 
 * in order to support record type label overrides. See: http://www.ca-peterson.com/2011/10/tales-of-isv-supporting-override-labels.html
 * @author chris@ca-peterson.com
 **/
 
 //TODO: support description overrides
public with sharing class RecordTypeDescribe {
	private static Map<String,Map<id,RecordTypeDescribe>> cache {
		get{
			if(cache == null)
				cache = new Map<String,Map<id,RecordTypeDescribe>>();
			return cache;
		}
		set;
	}
	private static Map<String,RecordTypeDescribe> defaultsCache {
		get{
			if(defaultsCache == null)
				defaultsCache = new Map<String,RecordTypeDescribe>();
			return defaultsCache;
		}
		set;
	}
	
	public Id recordTypeId {get; set;}
	public String internalLabel {get; set;}
	public String label {get; set;}
	public String developerName {get; set;}
	public String namespacePrefix {get; set;}
	public String description {get; set;}
	public String sObjectType {get; set;}
	public boolean isActive {get; set;}
	public boolean isDefault {get; set;}
	private boolean isAvailable;
	
	public RecordTypeDescribe(RecordType rt, Schema.RecordTypeInfo rti){
		if(rti == null)
			throw new ArgumentException('Second (Schema.RecordTypeInfo parameter) may not be null.');
		if(rt.id != rti.getRecordTypeId())
			throw new ArgumentException('Arguments must be for the same record type.');
		recordTypeId = rti.getRecordTypeId();
		internalLabel = rt.name;
		label = rti.getName();
		developerName = rt.DeveloperName;
		namespacePrefix = rt.NamespacePrefix;
		description = rt.Description;
		sObjectType = rt.SobjectType;
		isActive = rt.IsActive;
		isAvailable = rti.isAvailable();
		isDefault = rti.isDefaultRecordTypeMapping();
	}
	
	//returns true if the current user can create new record with this record type
	public boolean getIsAvailable(){
		return isAvailable;
	}
	
	public static RecordTypeDescribe getDefault(Schema.sObjectType objType){
		String objName = objType.getDescribe().getName().toLowerCase();
		if(!cache.containsKey(objName))
			fillCache(objType);
		return defaultsCache.get(objName); 
	}

	//TODO: refactor common code out of this and getAvailable
	public static Map<id,RecordTypeDescribe> getActive(Schema.sObjectType objType){
		Map<id,RecordTypeDescribe> result = new Map<id,RecordTypeDescribe>();
		String objName = objType.getDescribe().getName().toLowerCase();
		if(!cache.containsKey(objName))
			fillCache(objType);
		for(RecordTypeDescribe rtd:cache.get(objName).values() ){
			if(rtd.isActive)
				result.put(rtd.recordTypeId,rtd);
		}
		return result;
	}
	public static Map<id,RecordTypeDescribe> getAvailable(Schema.sObjectType objType){
		Map<id,RecordTypeDescribe> result = new Map<id,RecordTypeDescribe>();
		String objName = objType.getDescribe().getName().toLowerCase();
		if(!cache.containsKey(objName))
			fillCache(objType);
		for(RecordTypeDescribe rtd:cache.get(objName).values() ){
			if(rtd.getIsAvailable())
				result.put(rtd.recordTypeId,rtd);
		}
		return result;
	}
	
	public static Map<id,RecordTypeDescribe> getAll(Schema.sObjectType objType){
		String objName = objType.getDescribe().getName().toLowerCase();
		if(!cache.containsKey(objName))
			fillCache(objType);
		return cache.get(objName);
	}
	
	private static void fillCache(Schema.sObjectType objType){
		String objName = objType.getDescribe().getName().toLowerCase();
		Map<id,Schema.RecordTypeInfo> rtis = objType.getDescribe().getRecordTypeInfosById();
		List<RecordType> rtsobjs = [SELECT id, name, developerName, isActive, Description, sObjectType, namespacePrefix FROM RecordType WHERE sObjectType = :objType.getDescribe().getName()];
		
		Map<id,RecordTypeDescribe> result = new Map<id,RecordTypeDescribe>();
		for(RecordType rt:rtsobjs){
			Schema.RecordTypeInfo rti = rtis.get(rt.id);
			RecordTypeDescribe rtd = new RecordTypeDescribe(rt,rti);
			result.put(rt.id,rtd);
			if(rti.isDefaultRecordTypeMapping()) 
				defaultsCache.put(objName,rtd);
		}
		cache.put(objName,result);
	}

	public class ArgumentException extends Exception{}
}