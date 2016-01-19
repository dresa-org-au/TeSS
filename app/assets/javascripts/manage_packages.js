/**
 * Created by Niall Beard on 07/01/2016.
 *
 * Taken from materials_form.js
 *
 * Dropdown Option
 *  - For selecting dropdown options such as materials and events
 *  - Functions: Select, Delete
 */


$(document).ready(function(){
    /*
     * User selects a new material to add the package.
     * This adds a new added item and removes it from the dropdown
     * */
    $(document.body).on('click', '.dropdown-option', function(e){
        var selected_val = $(this).val();
        if (selected_val != ''){
            var field_name = $(this).parent().attr('data-field');
            var selected_text = $(this).text();
            add_selected_dropdown_item(field_name, selected_val, selected_text);
            $('#' + field_name + '-id-' + selected_val).remove();
        }
    })
    /*
     * User removes a material from the staged package/material list.
     * This adds the material back into the dropdown options.
     */
    $(document.body).on('click', '.dropdown-option-delete', function(e){
        var list_item = $(this).parent();
        add_dropdown_option($(this).attr('data-field'),
            $(this).attr('data-name'),
            $(this).attr('data-value'));
        list_item.remove()
    })

    /*FUNCTIONS*/
    /*
     * Adds a new selected item to the field_name div with the values and names passed
     */
    function add_selected_dropdown_item(field_name, value, name){
        var label = '<input type="text" class="multiple-input" data-field="package" name="package[' + field_name + '_ids][]" ' +
            'value="' + value + '" style="display:none;"> ' + name + '</text>';
        var delete_button = '<input type="button" value="x" class="dropdown-option-delete" data-field="package"' +
            'data-value="' + value + '" data-name="' + name + '"/>';

        var list_item_div = $('<div class="list-item">').appendTo('.' + field_name);
        $(label).appendTo(list_item_div);
        $(delete_button).appendTo(list_item_div);
    }
    /* Adds a new option to the list of dropdown options. Used when a package is deselected (e.g. delete button pressed)"*/
    function add_dropdown_option(field_name, name, value){
        $('<li class="dropdown-option" id="' + field_name + '-id-' + value + '" ' +
            'value="' + value + '"><a>' + name + '</a></li>').appendTo('.' + field_name + '-options')
    }
})