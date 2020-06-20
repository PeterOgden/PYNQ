import os
import pytest
import pynq

VERSIONS = [
    "2016.4"
]

FORMATS = [
    "hwh",
    "tcl"
]

def _parse(name, version, ext):
    if ext == 'hwh':
        ParseType = pynq.pl_server.hwh_parser._HWHZynq
    elif ext == "tcl":
        ParseType = pynq.pl_server.tcl_parser._TCLZynq
    basedir = os.path.join(os.path.dirname(__file__), 'data', version)
    return ParseType(os.path.join(basedir, name + "." + ext))


def check_ip(desc, ext, expected_address, check_register=True):
    assert desc['phys_addr'] == expected_address
    assert desc['addr_range'] == 65536
    assert desc['type'] == "user.org:user:pynq_test:1.0"
    if ext == "hwh":
        if check_register:
            registers = desc['registers']
            assert 'CTRL0' in registers
            assert 'CTRL1' in registers
            assert registers['CTRL0']['size'] == 4
            assert registers['CTRL1']['size'] == 4
            assert registers['CTRL0']['address_offset'] == 0
            assert registers['CTRL1']['address_offset'] == 4
        params = desc['parameters']
        assert params['C_M_AXI_DRAM_ADDR_WIDTH'] == '32'
    

@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_simple(version, ext):
    parser = _parse("simple", version, ext)
    assert 'pynq_test' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test'], ext, 0x43C00000)

    
@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_interrupt(version, ext):
    parser = _parse("interrupt", version, ext)
    assert 'pynq_test' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test'], ext, 0x43C00000)
    expected_int_pins = {
        'pynq_test/interrupt_bus': {'controller': '', 
                                    'index': 0,
                                    'fullpath': 'pynq_test/interrupt_bus'}
    }
    expected_int_controllers = {}
    assert parser.interrupt_pins.items() >= expected_int_pins.items()
    assert parser.interrupt_controllers == expected_int_controllers

@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_interrupt_concat(version, ext):
    parser = _parse("interrupt_concat", version, ext)
    assert 'pynq_test' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test'], ext, 0x43C00000)
    expected_int_pins = {
        'pynq_test/interrupt_bus': {'controller': '', 
                                    'index': 0,
                                    'fullpath': 'pynq_test/interrupt_bus'},
        'pynq_test/interrupt_wire': {'controller': '', 
                                    'index': 1,
                                    'fullpath': 'pynq_test/interrupt_wire'},
    }
    expected_int_controllers = {}
    assert parser.interrupt_pins.items() >= expected_int_pins.items()
    assert parser.interrupt_controllers == expected_int_controllers


@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_interrupt_controller(version, ext):
    parser = _parse("interrupt_controller", version, ext)
    assert 'pynq_test' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test'], ext, 0x43C00000)
    expected_int_pins = {
        'pynq_test/interrupt_bus': {'controller': 'pynq_interrupts', 
                                    'index': 0,
                                    'fullpath': 'pynq_test/interrupt_bus'},
        'pynq_test/interrupt_wire': {'controller': 'pynq_interrupts', 
                                    'index': 1,
                                    'fullpath': 'pynq_test/interrupt_wire'},
    }
    expected_int_controllers = {
        'pynq_interrupts': {'parent': '', 'index': 0}
    }
    assert parser.interrupt_pins.items() >= expected_int_pins.items()
    assert parser.interrupt_controllers == expected_int_controllers
    

@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_interrupt_standard(version, ext):
    parser = _parse("interrupt_standard", version, ext)
    assert 'pynq_test' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test'], ext, 0x43C00000)
    expected_int_pins = {
        'pynq_test/interrupt_bus': {'controller': 'pynq_interrupts', 
                                    'index': 0,
                                    'fullpath': 'pynq_test/interrupt_bus'},
        'pynq_test/interrupt_wire': {'controller': 'pynq_interrupts', 
                                    'index': 1,
                                    'fullpath': 'pynq_test/interrupt_wire'},
    }
    expected_int_controllers = {
        'pynq_interrupts': {'parent': '', 'index': 0}
    }
    assert parser.interrupt_pins.items() >= expected_int_pins.items()
    assert parser.interrupt_controllers == expected_int_controllers

    
@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_interrupt_controller_direct(version, ext):
    parser = _parse("interrupt_controller_direct", version, ext)
    assert 'pynq_test' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test'], ext, 0x43C00000)
    expected_int_pins = {
        'pynq_test/interrupt_wire': {'controller': 'pynq_interrupts', 
                                    'index': 0,
                                    'fullpath': 'pynq_test/interrupt_wire'},
    }
    expected_int_controllers = {
        'pynq_interrupts': {'parent': '', 'index': 0}
    }
    assert parser.interrupt_pins.items() >= expected_int_pins.items()
    assert parser.interrupt_controllers == expected_int_controllers

    
@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_gpio(version, ext):
    parser = _parse("gpio", version, ext)
    assert 'pynq_test' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test'], ext, 0x43C00000)
    assert 'pynq_slice' in parser.gpio_dict
    assert parser.gpio_dict['pynq_slice']['state'] == None
    assert parser.gpio_dict['pynq_slice']['index'] == 2
    assert 'pynq_test/gpio_in' in parser.gpio_dict['pynq_slice']['pins']

@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_hierarchy(version, ext):
    parser = _parse("hierarchy", version, ext)
    assert 'pynq_test' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test'], ext, 0x43C00000)
    assert 'hier/inner' in parser.ip_dict
    check_ip(parser.ip_dict['hier/inner'], ext, 0x43C10000)
    expected_int_pins = {
        #'hier/interrupt_bus': {'controller': 'pynq_interrupts', 
        #                            'index': 0,
        #                            'fullpath': 'hier/interrupt_bus'},
        #'hier/interrupt_wire': {'controller': 'pynq_interrupts', 
        #                            'index': 1,
        #                            'fullpath': 'hier/interrupt_wire'},
        'hier/inner/interrupt_bus': {'controller': 'pynq_interrupts', 
                                    'index': 0,
                                    'fullpath': 'hier/inner/interrupt_bus'},
        'hier/inner/interrupt_wire': {'controller': 'pynq_interrupts', 
                                    'index': 1,
                                    'fullpath': 'hier/inner/interrupt_wire'},
    }
    expected_int_controllers = {
        'pynq_interrupts': {'parent': '', 'index': 0}
    }
    assert parser.interrupt_pins.items() >= expected_int_pins.items()
    assert parser.interrupt_controllers == expected_int_controllers
    assert 'pynq_slice' in parser.gpio_dict
    assert parser.gpio_dict['pynq_slice']['state'] == None
    assert parser.gpio_dict['pynq_slice']['index'] == 2
    assert 'hier/inner/gpio_in' in parser.gpio_dict['pynq_slice']['pins']
    #assert 'hier/gpio_in' in parser.gpio_dict['pynq_slice']['pins']
    assert 'hier' in parser.hierarchy_dict
    hier = parser.hierarchy_dict['hier']
    assert 'inner' in hier['ip']
    assert hier['ip']['inner'] == parser.ip_dict['hier/inner']
     


    
@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_hierarchy_concat(version, ext):
    parser = _parse("hierarchy_concat", version, ext)
    assert 'pynq_test' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test'], ext, 0x43C00000)
    assert 'hier/inner' in parser.ip_dict
    check_ip(parser.ip_dict['hier/inner'], ext, 0x43C10000)
    expected_int_pins = {
        'hier/inner/interrupt_bus': {'controller': 'pynq_interrupts', 
                                    'index': 0,
                                    'fullpath': 'hier/inner/interrupt_bus'},
        'hier/inner/interrupt_wire': {'controller': 'pynq_interrupts', 
                                    'index': 1,
                                    'fullpath': 'hier/inner/interrupt_wire'},
    }
    expected_int_controllers = {
        'pynq_interrupts': {'parent': '', 'index': 0}
    }
    assert parser.interrupt_pins.items() >= expected_int_pins.items()
    assert parser.interrupt_controllers == expected_int_controllers
    assert 'pynq_slice' in parser.gpio_dict
    assert parser.gpio_dict['pynq_slice']['state'] == None
    assert parser.gpio_dict['pynq_slice']['index'] == 2
    assert 'hier/inner/gpio_in' in parser.gpio_dict['pynq_slice']['pins']
    #assert 'hier/gpio_in' in parser.gpio_dict['pynq_slice']['pins']
    assert 'hier' in parser.hierarchy_dict
    hier = parser.hierarchy_dict['hier']
    assert 'inner' in hier['ip']
    assert hier['ip']['inner'] == parser.ip_dict['hier/inner']

    
@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_hierarchy_intc(version, ext):
    parser = _parse("hierarchy_intc", version, ext)
    assert 'pynq_test' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test'], ext, 0x43C00000)
    assert 'hier/inner' in parser.ip_dict
    check_ip(parser.ip_dict['hier/inner'], ext, 0x43C10000)
    expected_int_pins = {
        'hier/inner/interrupt_bus': {'controller': 'hier/hier_interrupts', 
                                    'index': 0,
                                    'fullpath': 'hier/inner/interrupt_bus'},
        'hier/inner/interrupt_wire': {'controller': 'hier/hier_interrupts', 
                                    'index': 1,
                                    'fullpath': 'hier/inner/interrupt_wire'},
        #'hier/interrupt': {'controller': '', 'index': 0, 'fullpath': 'hier/interrupt'}
    }
    expected_int_controllers = {
        'hier/hier_interrupts': {'parent': '', 'index': 0}
    }
    assert parser.interrupt_pins.items() >= expected_int_pins.items()
    assert parser.interrupt_controllers == expected_int_controllers
    assert 'pynq_slice' in parser.gpio_dict
    assert parser.gpio_dict['pynq_slice']['state'] == None
    assert parser.gpio_dict['pynq_slice']['index'] == 2
    assert 'hier/inner/gpio_in' in parser.gpio_dict['pynq_slice']['pins']
    #assert 'hier/gpio_in' in parser.gpio_dict['pynq_slice']['pins']
    assert 'hier' in parser.hierarchy_dict
    hier = parser.hierarchy_dict['hier']
    assert 'inner' in hier['ip']
    assert hier['ip']['inner'] == parser.ip_dict['hier/inner']

    
@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_hierarchy_slice(version, ext):
    parser = _parse("hierarchy_slice", version, ext)
    assert 'pynq_test' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test'], ext, 0x43C00000)
    assert 'hier/inner' in parser.ip_dict
    check_ip(parser.ip_dict['hier/inner'], ext, 0x43C10000)
    assert 'hier/hier_slice' in parser.gpio_dict
    assert parser.gpio_dict['hier/hier_slice']['state'] == None
    assert parser.gpio_dict['hier/hier_slice']['index'] == 2
    assert 'hier/inner/gpio_in' in parser.gpio_dict['hier/hier_slice']['pins']
    assert 'hier' in parser.hierarchy_dict
    hier = parser.hierarchy_dict['hier']
    assert 'inner' in hier['ip']
    assert hier['ip']['inner'] == parser.ip_dict['hier/inner']

    
@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_nested_hierarchy(version, ext):
    parser = _parse("nested_hierarchy", version, ext)
    assert 'pynq_test' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test'], ext, 0x43C00000)
    assert 'layer1/middle' in parser.ip_dict
    check_ip(parser.ip_dict['layer1/middle'], ext, 0x43C20000)
    assert 'layer1/layer2/inner' in parser.ip_dict
    check_ip(parser.ip_dict['layer1/layer2/inner'], ext, 0x43C10000)
    expected_int_pins = {
        'layer1/middle/interrupt_bus': {'controller': 'layer1/layer1_interrupts', 
                                    'index': 0,
                                    'fullpath': 'layer1/middle/interrupt_bus'},
        'layer1/middle/interrupt_wire': {'controller': 'layer1/layer1_interrupts', 
                                    'index': 1,
                                    'fullpath': 'layer1/middle/interrupt_wire'},
#        'layer1/layer2/inner/interrupt_bus': {'controller': 'layer1/layer2/layer2_interrupts', 
#                                    'index': 0,
#                                    'fullpath': 'layer1/layer2/inner/interrupt_bus'},
#        'layer1/layer2/inner/interrupt_wire': {'controller': 'layer1/layer2/layer2_interrupts', 
#                                    'index': 1,
#                                    'fullpath': 'layer1/layer2/inner/interrupt_wire'},
        #'hier/interrupt': {'controller': '', 'index': 0, 'fullpath': 'hier/interrupt'}
    }
    expected_int_controllers = {
        'layer1/layer1_interrupts': {'parent': '', 'index': 0},
#        'layer1/layer2/layer2_interrupts': {'parent': 'layer1/layer1_interrupts', 'index': 2}
    }
    assert parser.interrupt_pins.items() >= expected_int_pins.items()
    assert parser.interrupt_controllers.items() >= expected_int_controllers.items()
    assert 'layer1' in parser.hierarchy_dict
    layer1 = parser.hierarchy_dict['layer1']
    assert 'layer2' in layer1['hierarchies']
    layer2 = layer1['hierarchies']['layer2']
    assert 'middle' in layer1['ip']
    assert 'inner' in layer2['ip']
    assert layer1['ip']['middle'] == parser.ip_dict['layer1/middle']
    assert layer2['ip']['inner'] == parser.ip_dict['layer1/layer2/inner']

    
@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_multiple_concat(version, ext):
    parser = _parse("multiple_concat", version, ext)
    assert 'pynq_test_1' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test_1'], ext, 0x43C00000)
    assert 'pynq_test_2' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test_2'], ext, 0x43C10000)
    expected_int_pins = {
        'pynq_test_1/interrupt_bus': {'controller': 'pynq_interrupts', 
                                    'index': 0,
                                    'fullpath': 'pynq_test_1/interrupt_bus'},
        'pynq_test_1/interrupt_wire': {'controller': 'pynq_interrupts', 
                                    'index': 1,
                                    'fullpath': 'pynq_test_1/interrupt_wire'},
        'pynq_test_2/interrupt_bus': {'controller': 'pynq_interrupts', 
                                    'index': 2,
                                    'fullpath': 'pynq_test_2/interrupt_bus'},
        'pynq_test_2/interrupt_wire': {'controller': 'pynq_interrupts', 
                                    'index': 3,
                                    'fullpath': 'pynq_test_2/interrupt_wire'},
    }
    expected_int_controllers = {
        'pynq_interrupts': {'parent': '', 'index': 0}
    }
    assert parser.interrupt_pins.items() >= expected_int_pins.items()
    assert parser.interrupt_controllers == expected_int_controllers

    
@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_multiple_concat_hierarchy(version, ext):
    parser = _parse("multiple_concat_hierarchy", version, ext)
    assert 'pynq_test_1' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test_1'], ext, 0x43C00000)
    assert 'hier/pynq_test_2' in parser.ip_dict
    check_ip(parser.ip_dict['hier/pynq_test_2'], ext, 0x43C10000)
    expected_int_pins = {
        'pynq_test_1/interrupt_bus': {'controller': 'pynq_interrupts', 
                                    'index': 0,
                                    'fullpath': 'pynq_test_1/interrupt_bus'},
        'pynq_test_1/interrupt_wire': {'controller': 'pynq_interrupts', 
                                    'index': 1,
                                    'fullpath': 'pynq_test_1/interrupt_wire'},
        'hier/pynq_test_2/interrupt_bus': {'controller': 'pynq_interrupts', 
                                    'index': 2,
                                    'fullpath': 'hier/pynq_test_2/interrupt_bus'},
        'hier/pynq_test_2/interrupt_wire': {'controller': 'pynq_interrupts', 
                                    'index': 3,
                                    'fullpath': 'hier/pynq_test_2/interrupt_wire'},
    }
    expected_int_controllers = {
        'pynq_interrupts': {'parent': '', 'index': 0}
    }
    assert parser.interrupt_pins.items() >= expected_int_pins.items()
    assert parser.interrupt_controllers == expected_int_controllers

    
@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_gpio_conflict(version, ext):
    parser = _parse("gpio_conflict", version, ext)
    assert 'pynq_test_0' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test_0'], ext, 0x43C10000)
    assert 'pynq_test_1' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test_1'], ext, 0x43C00000)
    assert 'pynq_slice_0' in parser.gpio_dict
    assert parser.gpio_dict['pynq_slice_0']['state'] == None
    assert parser.gpio_dict['pynq_slice_0']['index'] == 2
    assert 'pynq_test_0/gpio_in' in parser.gpio_dict['pynq_slice_0']['pins']
    assert 'pynq_slice_1' in parser.gpio_dict
    assert parser.gpio_dict['pynq_slice_1']['state'] == None
    assert parser.gpio_dict['pynq_slice_1']['index'] == 2
    assert 'pynq_test_1/gpio_in' in parser.gpio_dict['pynq_slice_1']['pins']

    
@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_ps_rename(version, ext):
    parser = _parse("ps_rename", version, ext)
    assert 'pynq_test' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test'], ext, 0x43C00000)

    
@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_second_master(version, ext):
    parser = _parse("second_master", version, ext)
    assert 'pynq_test' in parser.ip_dict
    check_ip(parser.ip_dict['pynq_test'], ext, 0x43C00000)
    
@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_out_of_context(version, ext):
    parser = _parse("out_of_context", version, ext)
    assert 'middle' in parser.ip_dict
    check_ip(parser.ip_dict['middle'], ext, 0x44A10000, check_register=False)
    assert 'layer2/inner' in parser.ip_dict
    check_ip(parser.ip_dict['layer2/inner'], ext, 0x44A00000, check_register=False)


@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_clocks_default(version, ext):
    parser = _parse("clocks_default", version, ext)
    cd = parser.clock_dict
    assert list(cd.keys()) == [0, 1, 2, 3]
    assert cd[0]['enable'] == 1
    assert cd[1]['enable'] == 0
    assert cd[2]['enable'] == 0
    assert cd[3]['enable'] == 0
    assert cd[0]['divisor0'] == 8
    assert cd[0]['divisor1'] == 4


@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_clocks_board(version, ext):
    parser = _parse("clocks_board", version, ext)
    cd = parser.clock_dict
    assert list(cd.keys()) == [0, 1, 2, 3]
    assert cd[0]['enable'] == 1
    assert cd[1]['enable'] == 0
    assert cd[2]['enable'] == 0
    assert cd[3]['enable'] == 0
    assert cd[0]['divisor0'] == 5
    assert cd[0]['divisor1'] == 4


@pytest.mark.parametrize("version", VERSIONS)
@pytest.mark.parametrize("ext", FORMATS)
def test_clocks_custom(version, ext):
    parser = _parse("clocks_custom", version, ext)
    cd = parser.clock_dict
    assert list(cd.keys()) == [0, 1, 2, 3]
    # assert cd[0]['enable'] == 0
    assert cd[1]['enable'] == 1
    assert cd[2]['enable'] == 1
    assert cd[3]['enable'] == 1
    assert cd[1]['divisor0'] == 5
    assert cd[1]['divisor1'] == 2
    assert cd[2]['divisor0'] == 7
    assert cd[2]['divisor1'] == 1
    assert cd[3]['divisor0'] == 5
    assert cd[3]['divisor1'] == 1
