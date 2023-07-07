/**
 * @description  This is the interface to be implemented by all trigger handler classes.
 *               Simply complete the implemented methods which are required for the trigger. 
 *               Leave any events that you do not need blank.
 * @author Kostiantyn Murin
 * @date 18-06-2023
 */
public interface ITriggerHandler {
    void beforeInsert(List<SObject> newList);

    void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap);
  
    void beforeDelete(Map<Id, SObject> oldMap);
  
    void afterInsert(Map<Id, SObject> newMap);
  
    void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap);
  
    void afterDelete(Map<Id, SObject> oldMap);
  
    void afterUndelete(Map<Id, SObject> oldMap);
}