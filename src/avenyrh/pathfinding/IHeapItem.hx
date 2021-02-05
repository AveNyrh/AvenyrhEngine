package avenyrh.pathfinding;

interface IHeapItem
{
    /**
     * Index of each item in the Heap
     */
    var heapIndex : Int;
    /**
     * Compare to method
     */
    function compareTo(other : IHeapItem): Int;
}