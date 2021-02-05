package avenyrh.pathfinding;

import avenyrh.pathfinding.IHeapItem;

//Haxe version of Sebastian Lague pathfinding heap optimisation
//https://www.youtube.com/watch?v=3Dw5d7PlcTM
class Heap 
{
    var items : Array<IHeapItem>;

    /**
     * Number of items in the heap
     */
    public var count (default, null) : Int;

    public function new() 
    {
        items = [];
        count = 0;  
    }

    //--------------------
    //Public API
    //--------------------
    /**
     * Adds the item to the Heap
     */
    public function add(item : IHeapItem) 
    {
        item.heapIndex = count;
        items[count] = item;
        //items.push(item);
        sortUp(item);
        count++;
    }

    /**
     * Updates the item in the Heap (for now it sorts it up)
     */
    public function updateItem(item : IHeapItem)
    {
        sortUp(item);
    }

    /**
     * Removes the first item of the Heap, gives it in return and sorts the Heap
     */
    public function removeFirst() : IHeapItem
    {
        var item : IHeapItem = items[0];
        count--;
        items[0] = items[count];
        items[0].heapIndex = 0;
        sortDown(items[0]);
        return item;
    }

    /**
     * Returns true if the Heap contains the given item
     */
    public inline function contains(item : IHeapItem) : Bool
    {
        return items[item.heapIndex] == item;
    }

    //--------------------
    //Private API
    //--------------------
    /**
     * Sorts the item up in the Heap
     */
    function sortUp(item : IHeapItem)
    {
        var parentIndex : Int = Std.int((item.heapIndex - 1) / 2);

        while (true)
        {
            var parentItem : IHeapItem = items[parentIndex];

            if(item.compareTo(parentItem) > 0)
            {
                swap(item, parentItem);
            }
            else 
            {
                break;
            }

            parentIndex = Std.int((item.heapIndex - 1) / 2);
        }
    }

    /**
     * Sorts the item down in the Heap
     */
    function sortDown(item : IHeapItem)
    {
        while (true)
        {
            var childIndexLeft : Int = item.heapIndex * 2 + 1;
            var childIndexRight : Int = item.heapIndex * 2 + 2;
            var swapIndex : Int = 0;

            if(childIndexLeft < count)
            {
                swapIndex = childIndexLeft;

                if(childIndexRight < count)
                {
                    if(items[childIndexLeft].compareTo(items[childIndexRight]) < 0)
                    {
                        swapIndex = childIndexRight;
                    }
                }

                if(item.compareTo(items[swapIndex]) < 0)
                    swap(item, items[swapIndex]);
                else 
                    break;
            }
            else 
                return;
        }
    }

    /**
     * Swaps the two items in the Heap
     */
    function swap(itemA : IHeapItem, itemB : IHeapItem)
    {
        items[itemA.heapIndex] = itemB;
        items[itemB.heapIndex] = itemA;
        var itemAIndex : Int = itemA.heapIndex;
        itemA.heapIndex = itemB.heapIndex;
        itemB.heapIndex = itemAIndex;
    }
}