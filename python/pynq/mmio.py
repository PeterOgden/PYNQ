#   Copyright (c) 2016, Xilinx, Inc.
#   All rights reserved.
# 
#   Redistribution and use in source and binary forms, with or without 
#   modification, are permitted provided that the following conditions are met:
#
#   1.  Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#
#   2.  Redistributions in binary form must reproduce the above copyright 
#       notice, this list of conditions and the following disclaimer in the 
#       documentation and/or other materials provided with the distribution.
#
#   3.  Neither the name of the copyright holder nor the names of its 
#       contributors may be used to endorse or promote products derived from 
#       this software without specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
#   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
#   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
#   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
#   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
#   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#   OR BUSINESS INTERRUPTION). HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
#   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
#   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
#   ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

__author__      = "Yun Rock Qu"
__copyright__   = "Copyright 2016, Xilinx"
__email__       = "pynq_support@xilinx.com"


import os
import sys
import struct
import mmap
import math
from . import general_const
import numpy as np

class MMIO:
    """ This class exposes API for MMIO read and write.
    
    Attributes
    ----------
    virt_base : int
        The address of the page for the MMIO base address.
    virt_offset : int
        The offset of the MMIO base address from the virt_base.
    base_addr : int
        The base address, not necessarily page aligned.
    length : int
        The length in bytes of the address range.
    debug : bool
        Turn on debug mode if it is True.
    mem : mmap
        An mmap object created when mapping files to memory.
    
    """

    def __init__(self, base_addr, length = 4, debug = False):
        """Return a new MMIO object.
        
        Parameters
        ----------
        base_addr : int
            The base address of the MMIO.
        length : int
            The length in bytes; default is 4.
        debug : bool
            Turn on debug mode if it is True; default is False.
            
        """
        if base_addr < 0 or length < 0:
            raise ValueError("Negative offset or negative length.")
            
        euid = os.geteuid()
        if euid != 0:
            raise EnvironmentError('Root permissions required.')
        
        # Align the base address with the pages
        self.virt_base = base_addr & ~(mmap.PAGESIZE - 1)
        
        # Calculate base address offset w.r.t the base address
        self.virt_offset = base_addr - self.virt_base
        
        # Align the stop address with the words
        stop = base_addr + length
        if (stop % general_const.MMIO_WORD_MASK):
            stop = (stop + general_const.MMIO_WORD_LENGTH) & \
                    general_const.MMIO_WORD_MASK
        
        # Storing the base address and length
        self.base_addr = base_addr
        self.length = length
        
        self.debug = debug
        self._debug('MMIO(address, size) = ({0:x}, {1:x} bytes).',
                    self.base_addr,self.length)
                
        # Open file and mmap
        self.f = os.open(general_const.MMIO_FILE_NAME, os.O_RDWR | os.O_SYNC)
        self.mem = mmap.mmap(self.f, (self.length + self.virt_offset),
                            mmap.MAP_SHARED,
                            mmap.PROT_READ | mmap.PROT_WRITE,
                            offset = self.virt_base)

        self.array = np.frombuffer(self.mem, np.uint32, length >> 2, self.virt_offset)

    def read(self, offset = 0, length = 4):
        """The method to read data from MMIO.
        
        Parameters
        ----------
        offset : int
            The read offset from the MMIO base address.
        length : int
            The length of the data in bytes.
        
        Returns
        -------
        list
            A list of data read out from MMIO
        
        """
        if not length==4:
            raise ValueError("MMIO currently only supports 4-byte reads.")
        if offset < 0 or length < 0: 
            raise ValueError("Negative offset or negative length.")
        idx = offset >> 2
        if idx << 2 != offset:
            raise MemoryError('Read operation unaligned.')

        self._debug('Reading {0} bytes from offset {1:x}',
                    length, offset)

        # Read data out
        return int(self.array[idx])
        
    def write(self, offset, data):
        """The method to write data to MMIO.

        Parameters
        ----------
        offset : int
            The write offset from the MMIO base address.
        data : int / bytes
            The integer(s) to be written into MMIO.
        
        Returns
        -------
        None
        
        """
        if offset < 0: 
                raise ValueError("Negative offset.")

        idx = offset >> 2
        if idx << 2 != offset:
            raise MemoryError('Write operation not aligned.')

        if type(data) is int:
            self._debug('Writing 4 bytes to offset {0:x}: {1:x}',
                        offset, data)
            self.array[idx] = np.uint32(data)
        elif type(data) is bytes:
            length = len(data)
            num_words = length >> 2
            if (num_words << 2 != length):
                raise MemoryError('Need an integer number of words')
            buf = np.frombuffer(data, np.uint32, num_words, 0)
            self.array[offset:offset + num_words] = buf
        else:
            raise ValueError("Data type must be int or bytes.")

    def _debug(self, s, *args):
        """The method provides debug capabilities for this class.
        
        Parameters
        ----------
        s : str
            The debug information format string
        *args : any
            The arguments to be formatted
        Returns
        -------
        None
        
        """
        if self.debug: 
            print('MMIO Debug: {0}'.format(s.format(*args)))
