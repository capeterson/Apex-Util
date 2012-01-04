/**
 * Simple wrapper class to represent a record type sObject and RecordTypeInfo object all in one.
 * This object needs to be used in any ui-facing record type operations going forward 
 * in order to support record type label overrides. See: http://www.ca-peterson.com/2011/10/tales-of-isv-supporting-override-labels.html
 * @author cpeterson
 **/
 
 //TODO: support description overrides
global with sharing class RecordTypeDescribe {
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
	
	global Id recordTypeId {get; set;}
	global String internalLabel {get; set;}
	global String label {get; set;}
	global String developerName {get; set;}
	global String namespacePrefix {get; set;}
	global String description {get; set;}
	global String sObjectType {get; set;}
	global boolean isActive {get; set;}
	global boolean isDefault {get; set;}
	private boolean isAvailable;
	
	global RecordTypeDescribe(RecordType rt, Schema.RecordTypeInfo rti){
		if(rti == null)
			throw new Exceptions.ArgumentException('Second (Schema.RecordTypeInfo parameter) may not be null.');
		if(rt.id != rti.getRecordTypeId())
			throw new Exceptions.ArgumentException('Arguments must be for the same record type.');
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
	
	@deprecated
	global RecordTypeDescribe(Schema.RecordTypeInfo rti){
		System.assert(false,'This method should not be called directly.');
	}
	
	//returns true if the current user can create new record with this record type
	global boolean getIsAvailable(){
		return isAvailable;
	}
	
	global static RecordTypeDescribe getDefault(Schema.sObjectType objType){
		String objName = objType.getDescribe().getName().toLowerCase();
		if(!cache.containsKey(objName))
			fillCache(objType);
		return defaultsCache.get(objName); 
	}

	//TODO: refactor common code out of this and getAvailable
	global static Map<id,RecordTypeDescribe> getActive(Schema.sObjectType objType){
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
	global static Map<id,RecordTypeDescribe> getAvailable(Schema.sObjectType objType){
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
	
	global static Map<id,RecordTypeDescribe> getAll(Schema.sObjectType objType){
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
}