using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Collections.ObjectModel;
using System.Data;
using System.Runtime.CompilerServices;

namespace ExcelDataReader.Core
{

    internal enum STGTY : byte
    {
        STGTY_INVALID = 0,
        STGTY_STORAGE = 1,
        STGTY_STREAM = 2,
        STGTY_LOCKBYTES = 3,
        STGTY_PROPERTY = 4,
        STGTY_ROOT = 5
    }

    internal enum DECOLOR : byte
    {
        DE_RED = 0,
        DE_BLACK = 1
    }

    internal enum FATMARKERS : uint
    {
        FAT_EndOfChain = 0xFFFFFFFE,
        FAT_FreeSpace = 0xFFFFFFFF,
        FAT_FatSector = 0xFFFFFFFD,
        FAT_DifSector = 0xFFFFFFFC
    }

    internal enum BIFFTYPE : ushort
    {
        WorkbookGlobals = 0x0005,
        VBModule = 0x0006,
        Worksheet = 0x0010,
        Chart = 0x0020,
        v4MacroSheet = 0x0040,
        v4WorkbookGlobals = 0x0100
    }

    internal enum BIFFRECORDTYPE : ushort
    {
        INTERFACEHDR = 0x00E1,
        MMS = 0x00C1,
        INTERFACEEND = 0x00E2,
        WRITEACCESS = 0x005C,
        CODEPAGE = 0x0042,
        DSF = 0x0161,
        TABID = 0x013D,
        FNGROUPCOUNT = 0x009C,
        WINDOWPROTECT = 0x0019,
        PROTECT = 0x0012,
        PASSWORD = 0x0013,
        PROT4REV = 0x01AF,
        PROT4REVPASSWORD = 0x01BC,
        WINDOW1 = 0x003D,
        BACKUP = 0x0040,
        HIDEOBJ = 0x008D,
        RECORD1904 = 0x0022,
        REFRESHALL = 0x01B7,
        BOOKBOOL = 0x00DA,

        FONT = 0x0031,                  // Font record, BIFF2, 5 and later
        FONT_V34 = 0x0231,              // Font record, BIFF3, 4

        FORMAT = 0x041E,                // Format record, BIFF4 and later
        FORMAT_V23 = 0x001E,            // Format record, BIFF2, 3

        XF = 0x00E0,                    // Extended format record, BIFF5 and later
        XF_V4 = 0x0443,                 // Extended format record, BIFF4
        XF_V3 = 0x0243,                 // Extended format record, BIFF3
        XF_V2 = 0x0043,                 // Extended format record, BIFF2

        STYLE = 0x0293,
        BOUNDSHEET = 0x0085,
        COUNTRY = 0x008C,
        SST = 0x00FC,                   // Global string storage (for BIFF8)
        CONTINUE = 0x003C,
        EXTSST = 0x00FF,
        BOF = 0x0809,                   // BOF ID for BIFF5 and later
        BOF_V2 = 0x0009,                // BOF ID for BIFF2
        BOF_V3 = 0x0209,                // BOF ID for BIFF3
        BOF_V4 = 0x0409,                // BOF ID for BIFF5
        EOF = 0x000A,                   // End of block started with BOF
        CALCCOUNT = 0x000C,
        CALCMODE = 0x000D,
        PRECISION = 0x000E,
        REFMODE = 0x000F,
        DELTA = 0x0010,
        ITERATION = 0x0011,
        SAVERECALC = 0x005F,
        PRINTHEADERS = 0x002A,
        PRINTGRIDLINES = 0x002B,
        GUTS = 0x0080,
        WSBOOL = 0x0081,
        GRIDSET = 0x0082,
        DEFAULTROWHEIGHT = 0x0225,
        HEADER = 0x0014,
        FOOTER = 0x0015,
        HCENTER = 0x0083,
        VCENTER = 0x0084,
        PRINTSETUP = 0x00A1,
        DFAULTCOLWIDTH = 0x0055,
        DIMENSIONS = 0x0200,            // Size of area used for data
        ROW = 0x0208,                   // Row record
        WINDOW2 = 0x023E,
        SELECTION = 0x001D,
        INDEX = 0x020B,                 // Index record, unsure about signature
        DBCELL = 0x00D7,                // DBCell record, unsure about signature
        BLANK = 0x0201,                 // Empty cell
        BLANK_OLD = 0x0001,             // Empty cell, old format
        MULBLANK = 0x00BE,              // Equivalent of up to 256 blank cells
        INTEGER = 0x0202,               // Integer cell (0..65535)
        INTEGER_OLD = 0x0002,           // Integer cell (0..65535), old format
        NUMBER = 0x0203,                // Numeric cell
        NUMBER_OLD = 0x0003,            // Numeric cell, old format
        LABEL = 0x0204,                 // String cell (up to 255 symbols)
        LABEL_OLD = 0x0004,             // String cell (up to 255 symbols), old format
        LABELSST = 0x00FD,              // String cell with value from SST (for BIFF8)
        FORMULA = 0x0406,               // Formula cell
        FORMULA_OLD = 0x0006,           // Formula cell, old format
        BOOLERR = 0x0205,               // Boolean or error cell
        BOOLERR_OLD = 0x0005,           // Boolean or error cell, old format
        ARRAY = 0x0221,                 // Range of cells for multi-cell formula
        RK = 0x027E,                    // RK-format numeric cell
        MULRK = 0x00BD,                 // Equivalent of up to 256 RK cells
        RSTRING = 0x00D6,               // Rich-formatted string cell
        SHRFMLA = 0x04BC,               // One more formula optimization element
        SHRFMLA_OLD = 0x00BC,           // One more formula optimization element, old format
        STRING = 0x0207,                // And one more, for string formula results
        CF = 0x01B1,
        CODENAME = 0x01BA,
        CONDFMT = 0x01B0,
        DCONBIN = 0x01B5,
        DV = 0x01BE,
        DVAL = 0x01B2,
        HLINK = 0x01B8,
        MSODRAWINGGROUP = 0x00EB,
        MSODRAWING = 0x00EC,
        MSODRAWINGSELECTION = 0x00ED,
        PARAMQRY = 0x00DC,
        QSI = 0x01AD,
        SUPBOOK = 0x01AE,
        SXDB = 0x00C6,
        SXDBEX = 0x0122,
        SXFDBTYPE = 0x01BB,
        SXRULE = 0x00F0,
        SXEX = 0x00F1,
        SXFILT = 0x00F2,
        SXNAME = 0x00F6,
        SXSELECT = 0x00F7,
        SXPAIR = 0x00F8,
        SXFMLA = 0x00F9,
        SXFORMAT = 0x00FB,
        SXFORMULA = 0x0103,
        SXVDEX = 0x0100,
        TXO = 0x01B6,
        USERBVIEW = 0x01A9,
        USERSVIEWBEGIN = 0x01AA,
        USERSVIEWEND = 0x01AB,
        USESELFS = 0x0160,
        XL5MODIFY = 0x0162,
        OBJ = 0x005D,
        NOTE = 0x001C,
        SXEXT = 0x00DC,
        VERTICALPAGEBREAKS = 0x001A,
        XCT = 0x0059,

    }

    internal enum FORMULAERROR : byte
    {
        NULL = 0x00,    // #NULL!
        DIV0 = 0x07,    // #DIV/0!
        VALUE = 0x0F,   // #VALUE!
        REF = 0x17,     // #REF!
        NAME = 0x1D,    // #NAME?
        NUM = 0x24,     // #NUM!
        NA = 0x2A,      // #N/A
    }

    public class InvalidHeaderException : Exception
    {
        public InvalidHeaderException()
            : base() { }
        public InvalidHeaderException(string message)
            : base(message) { }
        public InvalidHeaderException(string message, Exception innerException)
            : base(message, innerException) { }
    }

    /// <summary>
    /// Represents Excel file header
    /// </summary>
    internal class XlsHeader
    {

        private byte[] m_bytes;
        private Stream m_file;

        private XlsHeader(Stream file)
        {
            m_bytes = new byte[512];
            m_file = file;
        }

        /// <summary>
        /// Reads Excel header from Stream
        /// </summary>
        /// <param name="file">Stream with Excel file</param>
        /// <returns>XlsHeader representing specified file</returns>
        public static XlsHeader ReadHeader(Stream file)
        {
            XlsHeader hdr = new XlsHeader(file);
            lock (file)
            {
                file.Seek(0, SeekOrigin.Begin);
                file.Read(hdr.m_bytes, 0, 512);
            }
            if (!hdr.IsSignatureValid)
                throw new InvalidHeaderException("Invalid file signature");
            if (hdr.ByteOrder != 0xFFFE)
                throw new FormatException("Invalid byte order specified");
            return hdr;
        }

        /// <summary>
        /// Returns file signature
        /// </summary>
        public ulong Signature
        {
            get { return BitConverter.ToUInt64(m_bytes, 0x0); }
        }

        /// <summary>
        /// Checks if file signature is valid
        /// </summary>
        public bool IsSignatureValid
        {
            get { return (Signature == 0xE11AB1A1E011CFD0); }
        }

        /// <summary>
        /// Typically filled with zeroes
        /// </summary>
        public Guid ClassId
        {
            get { byte[] tmp = new byte[16]; Buffer.BlockCopy(m_bytes, 0x8, tmp, 0, 16); return new Guid(tmp); }
        }

        /// <summary>
        /// Must be 0x003E
        /// </summary>
        public ushort Version
        {
            get { return BitConverter.ToUInt16(m_bytes, 0x18); }
        }

        /// <summary>
        /// Must be 0x0003
        /// </summary>
        public ushort DllVersion
        {
            get { return BitConverter.ToUInt16(m_bytes, 0x1A); }
        }

        /// <summary>
        /// Must be 0xFFFE
        /// </summary>
        public ushort ByteOrder
        {
            get { return BitConverter.ToUInt16(m_bytes, 0x1C); }
        }

        /// <summary>
        /// Typically 512
        /// </summary>
        public int SectorSize
        {
            get { return (1 << BitConverter.ToUInt16(m_bytes, 0x1E)); }
        }

        /// <summary>
        /// Typically 64
        /// </summary>
        public int MiniSectorSize
        {
            get { return (1 << BitConverter.ToUInt16(m_bytes, 0x20)); }
        }

        /// <summary>
        /// Number of FAT sectors
        /// </summary>
        public int FatSectorCount
        {
            get { return BitConverter.ToInt32(m_bytes, 0x2C); }
        }

        /// <summary>
        /// Number of first Root Directory Entry (Property Set Storage, FAT Directory) sector
        /// </summary>
        public uint RootDirectoryEntryStart
        {
            get { return BitConverter.ToUInt32(m_bytes, 0x30); }
        }

        /// <summary>
        /// Transaction signature, 0 for Excel
        /// </summary>
        public uint TransactionSignature
        {
            get { return BitConverter.ToUInt32(m_bytes, 0x34); }
        }

        /// <summary>
        /// Maximum size for small stream, typically 4096 bytes
        /// </summary>
        public uint MiniStreamCutoff
        {
            get { return BitConverter.ToUInt32(m_bytes, 0x38); }
        }

        /// <summary>
        /// First sector of Mini FAT, FAT_EndOfChain if there's no one
        /// </summary>
        public uint MiniFatFirstSector
        {
            get { return BitConverter.ToUInt32(m_bytes, 0x3C); }
        }

        /// <summary>
        /// Number of sectors in Mini FAT, 0 if there's no one
        /// </summary>
        public int MiniFatSectorCount
        {
            get { return BitConverter.ToInt32(m_bytes, 0x40); }
        }

        /// <summary>
        /// First sector of DIF, FAT_EndOfChain if there's no one
        /// </summary>
        public uint DifFirstSector
        {
            get { return BitConverter.ToUInt32(m_bytes, 0x44); }
        }

        /// <summary>
        /// Number of sectors in DIF, 0 if there's no one
        /// </summary>
        public int DifSectorCount
        {
            get { return BitConverter.ToInt32(m_bytes, 0x48); }
        }

        public Stream FileStream
        {
            get { return m_file; }
        }

        private XlsFat m_fat = null;

        /// <summary>
        /// Returns full FAT table, including DIF sectors
        /// </summary>
        public XlsFat FAT
        {
            get
            {
                if (m_fat != null)
                    return m_fat;

                uint value;
                int sectorSize = SectorSize;
                List<uint> sectors = new List<uint>(this.FatSectorCount);
                for (int i = 0x4C; i < sectorSize; i += 4)
                {
                    value = BitConverter.ToUInt32(m_bytes, i);
                    if (value == (uint)FATMARKERS.FAT_FreeSpace)
                        goto XlsHeader_Fat_Ready;
                    sectors.Add(value);
                }
                int difCount;
                if ((difCount = DifSectorCount) == 0)
                    goto XlsHeader_Fat_Ready;
                lock (m_file)
                {
                    uint difSector = DifFirstSector;
                    byte[] buff = new byte[sectorSize];
                    uint prevSector = 0;
                    while (difCount > 0)
                    {
                        sectors.Capacity += 128;
                        if (prevSector == 0 || (difSector - prevSector) != 1)
                            m_file.Seek((difSector + 1) * sectorSize, SeekOrigin.Begin);
                        prevSector = difSector;
                        m_file.Read(buff, 0, sectorSize);
                        for (int i = 0; i < 508; i += 4)
                        {
                            value = BitConverter.ToUInt32(buff, i);
                            if (value == (uint)FATMARKERS.FAT_FreeSpace)
                                goto XlsHeader_Fat_Ready;
                            sectors.Add(value);
                        }
                        value = BitConverter.ToUInt32(buff, 508);
                        if (value == (uint)FATMARKERS.FAT_FreeSpace)
                            break;
                        if ((difCount--) > 1)
                            difSector = value;
                        else
                            sectors.Add(value);
                    }
                }
            XlsHeader_Fat_Ready:
                m_fat = new XlsFat(this, sectors);
                return m_fat;
            }
        }

    }

    /// <summary>
    /// Represents Excel file FAT table
    /// </summary>
    internal class XlsFat
    {

        private List<uint> m_fat;
        private int m_sectors_for_fat;
        private int m_sectors;
        private XlsHeader m_hdr;

        /// <summary>
        /// Constructs FAT table from list of sectors
        /// </summary>
        /// <param name="hdr">XlsHeader</param>
        /// <param name="sectors">Sectors list</param>
        public XlsFat(XlsHeader hdr, List<uint> sectors)
        {
            m_hdr = hdr;
            m_sectors_for_fat = sectors.Count;
            uint sector = 0, prevSector = 0;
            int sectorSize = hdr.SectorSize;
            byte[] buff = new byte[sectorSize];
            Stream file = hdr.FileStream;
            using (MemoryStream ms = new MemoryStream(sectorSize * m_sectors_for_fat))
            {
                lock (file)
                {
                    for (int i = 0; i < sectors.Count; i++)
                    {
                        sector = sectors[i];
                        if (prevSector == 0 || (sector - prevSector) != 1)
                            file.Seek((sector + 1) * sectorSize, SeekOrigin.Begin);
                        prevSector = sector;
                        file.Read(buff, 0, sectorSize);
                        ms.Write(buff, 0, sectorSize);
                    }
                }
                ms.Seek(0, SeekOrigin.Begin);
                BinaryReader rd = new BinaryReader(ms);
                m_sectors = (int)ms.Length / 4;
                m_fat = new List<uint>(m_sectors);
                for (int i = 0; i < m_sectors; i++)
                    m_fat.Add(rd.ReadUInt32());
                rd.Close();
                ms.Close();
            }
        }

        /// <summary>
        /// Returns next data sector using FAT
        /// </summary>
        /// <param name="sector">Current data sector</param>
        /// <returns>Next data sector</returns>
        public uint GetNextSector(uint sector)
        {
            if (m_fat.Count <= sector)
                throw new ArgumentOutOfRangeException("Oops! There's no such sector in FAT.");
            uint value = m_fat[(int)sector];
            if (value == (uint)FATMARKERS.FAT_FatSector || value == (uint)FATMARKERS.FAT_DifSector)
                throw new InvalidOperationException("Oops! Trying to read stream from FAT area.");
            return value;
        }

        /// <summary>
        /// Resurns number of sectors used by FAT itself
        /// </summary>
        public int SectorsForFat
        {
            get { return m_sectors_for_fat; }
        }

        /// <summary>
        /// Returns number of sectors described by FAT
        /// </summary>
        public int SectorsCount
        {
            get { return m_sectors; }
        }

        /// <summary>
        /// Returns underlying XlsHeader object
        /// </summary>
        public XlsHeader Header
        {
            get { return m_hdr; }
        }

    }

    /// <summary>
    /// Represents an Excel file stream
    /// </summary>
    internal class XlsStream
    {

        protected Stream m_file;
        protected XlsFat m_fat;
        protected XlsHeader m_hdr;
        protected uint m_startSector;

        public XlsStream(XlsHeader hdr, uint startSector)
        {
            m_file = hdr.FileStream;
            m_fat = hdr.FAT;
            m_hdr = hdr;
            m_startSector = startSector;
        }

        /// <summary>
        /// Returns offset of first stream sector
        /// </summary>
        public uint BaseOffset
        {
            get { return (uint)((m_startSector + 1) * m_hdr.SectorSize); }
        }

        /// <summary>
        /// Returns number of first stream sector
        /// </summary>
        public uint BaseSector
        {
            get { return (m_startSector); }
        }

        /// <summary>
        /// Reads stream data from file
        /// </summary>
        /// <returns>Stream data</returns>
        public byte[] ReadStream()
        {
            uint sector = m_startSector, prevSector = 0;
            int sectorSize = m_hdr.SectorSize;
            byte[] buff = new byte[sectorSize];
            using (MemoryStream ms = new MemoryStream(sectorSize * 8))
            {
                lock (m_file)
                {
                    do
                    {
                        if (prevSector == 0 || (sector - prevSector) != 1)
                            m_file.Seek((sector + 1) * sectorSize, SeekOrigin.Begin);
                        prevSector = sector;
                        m_file.Read(buff, 0, sectorSize);
                        ms.Write(buff, 0, sectorSize);
                    }
                    while ((sector = m_fat.GetNextSector(sector)) != (uint)FATMARKERS.FAT_EndOfChain);
                }
                byte[] ret = ms.ToArray();
                ms.Close();
                return ret;
            }
        }

    }

    /// <summary>
    /// Represents Root Directory in file
    /// </summary>
    internal class XlsRootDirectory
    {
        private XlsHeader m_hdr;
        private List<XlsDirectoryEntry> m_entries;
        private XlsDirectoryEntry m_root = null;

        /// <summary>
        /// Creates Root Directory catalog from XlsHeader
        /// </summary>
        /// <param name="hdr">XlsHeader object</param>
        public XlsRootDirectory(XlsHeader hdr)
        {
            m_hdr = hdr;
            XlsStream stream = new XlsStream(hdr, hdr.RootDirectoryEntryStart);
            byte[] array = stream.ReadStream();
            byte[] tmp;
            XlsDirectoryEntry entry;
            List<XlsDirectoryEntry> entries = new List<XlsDirectoryEntry>();
            for (int i = 0; i < array.Length; i += XlsDirectoryEntry.Length)
            {
                tmp = new byte[XlsDirectoryEntry.Length];
                Buffer.BlockCopy(array, i, tmp, 0, tmp.Length);
                entries.Add(new XlsDirectoryEntry(tmp));
            }
            m_entries = entries;
            for (int i = 0; i < entries.Count; i++)
            {
                entry = entries[i];
                if (m_root == null && entry.EntryType == STGTY.STGTY_ROOT)
                    m_root = entry;
                if (entry.ChildSid != (uint)FATMARKERS.FAT_FreeSpace)
                    entry.Child = entries[(int)entry.ChildSid];
                if (entry.LeftSiblingSid != (uint)FATMARKERS.FAT_FreeSpace)
                    entry.LeftSibling = entries[(int)entry.LeftSiblingSid];
                if (entry.RightSiblingSid != (uint)FATMARKERS.FAT_FreeSpace)
                    entry.RightSibling = entries[(int)entry.RightSiblingSid];
            }
        }

        /// <summary>
        /// Searches for first matching entry by its name
        /// </summary>
        /// <param name="EntryName">String name of entry</param>
        /// <returns>Entry if found, null otherwise</returns>
        public XlsDirectoryEntry FindEntry(string EntryName)
        {
            foreach (XlsDirectoryEntry e in m_entries)
            {
                if (e.EntryName == EntryName)
                    return e;
            }
            return null;
        }

        /// <summary>
        /// Returns all entries in Root Directory
        /// </summary>
        public ReadOnlyCollection<XlsDirectoryEntry> Entries
        {
            get { return m_entries.AsReadOnly(); }
        }

        /// <summary>
        /// Returns the Root Entry
        /// </summary>
        public XlsDirectoryEntry RootEntry
        {
            get { return m_root; }
        }

    }

    /// <summary>
    /// Represents single Root Directory record
    /// </summary>
    internal class XlsDirectoryEntry
    {

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="bytes">byte array representing current object</param>
        public XlsDirectoryEntry(byte[] bytes)
        {
            if (bytes.Length < Length)
                throw new InvalidDataException("Oops! Array is too small.");
            m_bytes = bytes;
        }

        private byte[] m_bytes;

        /// <summary>
        /// Length of structure in bytes
        /// </summary>
        public const int Length = 0x80;

        /// <summary>
        /// Returns name of directory entry
        /// </summary>
        public string EntryName
        {
            get { return Encoding.Unicode.GetString(m_bytes, 0x0, EntryLength).TrimEnd('\0'); }
        }

        /// <summary>
        /// Returns size in bytes of entry's name (with terminating zero)
        /// </summary>
        public ushort EntryLength
        {
            get { return BitConverter.ToUInt16(m_bytes, 0x40); }
        }

        /// <summary>
        /// Returns entry type
        /// </summary>
        public STGTY EntryType
        {
            get { return (STGTY)Buffer.GetByte(m_bytes, 0x42); }
        }

        /// <summary>
        /// Retuns entry "color" in directory tree
        /// </summary>
        public DECOLOR EntryColor
        {
            get { return (DECOLOR)Buffer.GetByte(m_bytes, 0x43); }
        }

        /// <summary>
        /// Returns SID of left sibling
        /// </summary>
        /// <remarks>0xFFFFFFFF if there's no one</remarks>
        public uint LeftSiblingSid
        {
            get { return BitConverter.ToUInt32(m_bytes, 0x44); }
        }

        private XlsDirectoryEntry m_leftSibling = null;

        /// <summary>
        /// Returns left sibling
        /// </summary>
        public XlsDirectoryEntry LeftSibling
        {
            get { return m_leftSibling; }
            set { if (m_leftSibling == null) m_leftSibling = value; }
        }

        /// <summary>
        /// Returns SID of right sibling
        /// </summary>
        /// <remarks>0xFFFFFFFF if there's no one</remarks>
        public uint RightSiblingSid
        {
            get { return BitConverter.ToUInt32(m_bytes, 0x48); }
        }

        private XlsDirectoryEntry m_rightSibling = null;

        /// <summary>
        /// Returns right sibling
        /// </summary>
        public XlsDirectoryEntry RightSibling
        {
            get { return m_rightSibling; }
            set { if (m_rightSibling == null) m_rightSibling = value; }
        }

        /// <summary>
        /// Returns SID of first child (if EntryType is STGTY_STORAGE)
        /// </summary>
        /// <remarks>0xFFFFFFFF if there's no one</remarks>
        public uint ChildSid
        {
            get { return BitConverter.ToUInt32(m_bytes, 0x4C); }
        }

        private XlsDirectoryEntry m_child = null;

        /// <summary>
        /// Returns child
        /// </summary>
        public XlsDirectoryEntry Child
        {
            get { return m_child; }
            set { if (m_child == null) m_child = value; }
        }

        /// <summary>
        /// CLSID of container (if EntryType is STGTY_STORAGE)
        /// </summary>
        public Guid ClassId
        {
            get { byte[] tmp = new byte[16]; Buffer.BlockCopy(m_bytes, 0x50, tmp, 0, 16); return new Guid(tmp); }
        }

        /// <summary>
        /// Returns user flags of container (if EntryType is STGTY_STORAGE)
        /// </summary>
        public uint UserFlags
        {
            get { return BitConverter.ToUInt32(m_bytes, 0x60); }
        }

        /// <summary>
        /// Returns creation time of entry
        /// </summary>
        public DateTime CreationTime
        {
            get { return DateTime.FromFileTime(BitConverter.ToInt64(m_bytes, 0x64)); }
        }

        /// <summary>
        /// Returns last modification time of entry
        /// </summary>
        public DateTime LastWriteTime
        {
            get { return DateTime.FromFileTime(BitConverter.ToInt64(m_bytes, 0x6C)); }
        }

        /// <summary>
        /// First sector of data stream (if EntryType is STGTY_STREAM)
        /// </summary>
        /// <remarks>if EntryType is STGTY_ROOT, this can be first sector of MiniStream</remarks>
        public uint StreamFirstSector
        {
            get { return BitConverter.ToUInt32(m_bytes, 0x74); }
        }

        /// <summary>
        /// Size of data stream (if EntryType is STGTY_STREAM)
        /// </summary>
        /// <remarks>if EntryType is STGTY_ROOT, this can be size of MiniStream</remarks>
        public uint StreamSize
        {
            get { return BitConverter.ToUInt32(m_bytes, 0x78); }
        }

        /// <summary>
        /// Reserved, must be 0
        /// </summary>
        public uint PropType
        {
            get { return BitConverter.ToUInt32(m_bytes, 0x7C); }
        }

    }

    /// <summary>
    /// Represents a BIFF stream
    /// </summary>
    internal class XlsBiffStream : XlsStream
    {
        private byte[] bytes;
        private int m_offset;
        private int m_size;

        public XlsBiffStream(XlsHeader hdr, uint streamStart)
            : base(hdr, streamStart)
        {
            bytes = base.ReadStream();
            m_size = bytes.Length;
            m_offset = 0;
        }

        /// <summary>
        /// Always returns null, use biff-specific methods
        /// </summary>
        /// <returns></returns>
        [Obsolete("Use BIFF-specific methods for this stream")]
        public new byte[] ReadStream()
        {
            return bytes;
        }

        /// <summary>
        /// Returns size of BIFF stream in bytes
        /// </summary>
        public int Size
        {
            get { return m_size; }
        }

        /// <summary>
        /// Returns current position in BIFF stream
        /// </summary>
        public int Position
        {
            get { return m_offset; }
        }

        /// <summary>
        /// Sets stream pointer to the specified offset
        /// </summary>
        /// <param name="offset">Offset value</param>
        /// <param name="origin">Offset origin</param>
        [MethodImpl(MethodImplOptions.Synchronized)]
        public void Seek(int offset, SeekOrigin origin)
        {
            switch (origin)
            {
                case SeekOrigin.Begin:
                    m_offset = offset;
                    break;
                case SeekOrigin.Current:
                    m_offset += offset;
                    break;
                case SeekOrigin.End:
                    m_offset = m_size - offset;
                    break;
            }
            if (m_offset < 0)
                throw new IndexOutOfRangeException("Oops! Moving before stream start");
            if (m_offset > m_size)
                throw new IndexOutOfRangeException("Oops! Moving after stream end");
        }

        /// <summary>
        /// Reads record under cursor and advances cursor position to next record
        /// </summary>
        /// <returns></returns>
        [MethodImpl(MethodImplOptions.Synchronized)]
        public XlsBiffRecord Read()
        {
            XlsBiffRecord rec = XlsBiffRecord.GetRecord(bytes, (uint)m_offset);
            m_offset += rec.Size;
            if (m_offset > m_size)
                return null;
            return rec;
        }

        /// <summary>
        /// Reads record at specified offset, does not change cursor position
        /// </summary>
        /// <param name="offset"></param>
        /// <returns></returns>
        public XlsBiffRecord ReadAt(int offset)
        {
            XlsBiffRecord rec = XlsBiffRecord.GetRecord(bytes, (uint)offset);
            if (m_offset + rec.Size > m_size)
                return null;
            return rec;
        }

    }

    /// <summary>
    /// Represents basic BIFF record
    /// Base class for all BIFF record types
    /// </summary>
    internal class XlsBiffRecord
    {
        protected byte[] m_bytes;
        protected int m_readoffset;

        /// <summary>
        /// Basic entry constructor
        /// </summary>
        /// <param name="bytes">array representing this entry</param>
        protected XlsBiffRecord(byte[] bytes) : this(bytes, 0) { }

        protected XlsBiffRecord(byte[] bytes, uint offset)
        {
            if (bytes.Length - offset < 4)
                throw new InvalidDataException("Oops! Buffer size is less than minimum BIFF record size");
            m_bytes = bytes;
            m_readoffset = (int)(4 + offset);
            if (bytes.Length < offset + Size)
                throw new InvalidDataException("Oops! Buffer size is less than entry length.");
        }

        /// <summary>
        /// Returns record at specified offset
        /// </summary>
        /// <param name="bytes">byte array</param>
        /// <param name="offset">position in array</param>
        /// <returns></returns>
        public static XlsBiffRecord GetRecord(byte[] bytes, uint offset)
        {
            uint ID = BitConverter.ToUInt16(bytes, (int)offset);
            switch ((BIFFRECORDTYPE)ID)
            {
                case BIFFRECORDTYPE.BOF_V2:
                case BIFFRECORDTYPE.BOF_V3:
                case BIFFRECORDTYPE.BOF_V4:
                case BIFFRECORDTYPE.BOF:
                    return new XlsBiffBOF(bytes, offset);
                case BIFFRECORDTYPE.EOF:
                    return new XlsBiffEOF(bytes, offset);
                case BIFFRECORDTYPE.INTERFACEHDR:
                    return new XlsBiffInterfaceHdr(bytes, offset);

                case BIFFRECORDTYPE.SST:
                    return new XlsBiffSST(bytes, offset);

                case BIFFRECORDTYPE.INDEX:
                    return new XlsBiffIndex(bytes, offset);
                case BIFFRECORDTYPE.ROW:
                    return new XlsBiffRow(bytes, offset);
                case BIFFRECORDTYPE.DBCELL:
                    return new XlsBiffDbCell(bytes, offset);

                case BIFFRECORDTYPE.BLANK:
                case BIFFRECORDTYPE.BLANK_OLD:
                    return new XlsBiffBlankCell(bytes, offset);
                case BIFFRECORDTYPE.MULBLANK:
                    return new XlsBiffMulBlankCell(bytes, offset);
                case BIFFRECORDTYPE.LABEL:
                case BIFFRECORDTYPE.LABEL_OLD:
                case BIFFRECORDTYPE.RSTRING:
                    return new XlsBiffLabelCell(bytes, offset);
                case BIFFRECORDTYPE.LABELSST:
                    return new XlsBiffLabelSSTCell(bytes, offset);
                case BIFFRECORDTYPE.INTEGER:
                case BIFFRECORDTYPE.INTEGER_OLD:
                    return new XlsBiffIntegerCell(bytes, offset);
                case BIFFRECORDTYPE.NUMBER:
                case BIFFRECORDTYPE.NUMBER_OLD:
                    return new XlsBiffNumberCell(bytes, offset);
                case BIFFRECORDTYPE.RK:
                    return new XlsBiffRKCell(bytes, offset);
                case BIFFRECORDTYPE.MULRK:
                    return new XlsBiffMulRKCell(bytes, offset);
                case BIFFRECORDTYPE.FORMULA:
                case BIFFRECORDTYPE.FORMULA_OLD:
                    return new XlsBiffFormulaCell(bytes, offset);
                case BIFFRECORDTYPE.STRING:
                    return new XlsBiffFormulaString(bytes, offset);
                case BIFFRECORDTYPE.CONTINUE:
                    return new XlsBiffContinue(bytes, offset);
                case BIFFRECORDTYPE.DIMENSIONS:
                    return new XlsBiffDimensions(bytes, offset);
                case BIFFRECORDTYPE.BOUNDSHEET:
                    return new XlsBiffBoundSheet(bytes, offset);
                case BIFFRECORDTYPE.WINDOW1:
                    return new XlsBiffWindow1(bytes, offset);
                case BIFFRECORDTYPE.CODEPAGE:
                    return new XlsBiffSimpleValueRecord(bytes, offset);
                case BIFFRECORDTYPE.FNGROUPCOUNT:
                    return new XlsBiffSimpleValueRecord(bytes, offset);
                case BIFFRECORDTYPE.RECORD1904:
                    return new XlsBiffSimpleValueRecord(bytes, offset);
                case BIFFRECORDTYPE.BOOKBOOL:
                    return new XlsBiffSimpleValueRecord(bytes, offset);
                case BIFFRECORDTYPE.BACKUP:
                    return new XlsBiffSimpleValueRecord(bytes, offset);
                case BIFFRECORDTYPE.HIDEOBJ:
                    return new XlsBiffSimpleValueRecord(bytes, offset);
                case BIFFRECORDTYPE.USESELFS:
                    return new XlsBiffSimpleValueRecord(bytes, offset);
				// 05/01/2008 Paul..  Fix problem with boolean values. 
				// http://www.codeproject.com/KB/office/Excel_DataReader.aspx?display=PrintAll&fid=320417&df=90&mpp=25&noise=3&sort=Position&view=Quick&fr=51&select=2513532#xx0xx
				case BIFFRECORDTYPE.BOOLERR:
					return new XlsBiffBoolErrCell(bytes, offset);
                default:
                    return new XlsBiffRecord(bytes, offset);
            }

        }

        internal byte[] Bytes
        {
            get { return m_bytes; }
        }

        internal int Offset
        {
            get { return m_readoffset - 4; }
        }

        /// <summary>
        /// Returns type ID of this entry
        /// </summary>
        public BIFFRECORDTYPE ID
        {
            get { return (BIFFRECORDTYPE)BitConverter.ToUInt16(m_bytes, m_readoffset - 4); }
        }

        /// <summary>
        /// Returns data size of this entry
        /// </summary>
        public ushort RecordSize
        {
            get { return BitConverter.ToUInt16(m_bytes, m_readoffset - 2); }
        }

        /// <summary>
        /// Returns whole size of structure
        /// </summary>
        public int Size
        {
            get { return 4 + RecordSize; }
        }

        public byte ReadByte(int offset)
        {
            return Buffer.GetByte(m_bytes, m_readoffset + offset);
        }

        public ushort ReadUInt16(int offset)
        {
            return BitConverter.ToUInt16(m_bytes, m_readoffset + offset);
        }

        public uint ReadUInt32(int offset)
        {
            return BitConverter.ToUInt32(m_bytes, m_readoffset + offset);
        }

        public ulong ReadUInt64(int offset)
        {
            return BitConverter.ToUInt64(m_bytes, m_readoffset + offset);
        }

        public short ReadInt16(int offset)
        {
            return BitConverter.ToInt16(m_bytes, m_readoffset + offset);
        }

        public int ReadInt32(int offset)
        {
            return BitConverter.ToInt32(m_bytes, m_readoffset + offset);
        }

        public long ReadInt64(int offset)
        {
            return BitConverter.ToInt64(m_bytes, m_readoffset + offset);
        }

        public byte[] ReadArray(int offset, int size)
        {
            byte[] tmp = new byte[size];
            Buffer.BlockCopy(m_bytes, m_readoffset + offset, tmp, 0, size);
            return tmp;
        }

        public float ReadFloat(int offset)
        {
            return BitConverter.ToSingle(m_bytes, m_readoffset + offset);
        }

        public double ReadDouble(int offset)
        {
            return BitConverter.ToDouble(m_bytes, m_readoffset + offset);
        }

    }

    /// <summary>
    /// Represents BIFF BOF record
    /// </summary>
    internal class XlsBiffBOF : XlsBiffRecord
    {

        internal XlsBiffBOF(byte[] bytes) : this(bytes, 0) { }
        internal XlsBiffBOF(byte[] bytes, uint offset) : base(bytes, offset) { }

        /// <summary>
        /// Version
        /// </summary>
        public ushort Version
        {
            get { return base.ReadUInt16(0x0); }
        }

        /// <summary>
        /// Type of BIFF block
        /// </summary>
        public BIFFTYPE Type
        {
            get { return (BIFFTYPE)base.ReadUInt16(0x2); }
        }

        /// <summary>
        /// Creation ID
        /// </summary>
        /// <remarks>Not used before BIFF5</remarks>
        public ushort CreationID
        {
            get
            {
                if (RecordSize < 6) return 0;
                return base.ReadUInt16(0x4);
            }
        }

        /// <summary>
        /// Creation year
        /// </summary>
        /// <remarks>Not used before BIFF5</remarks>
        public ushort CreationYear
        {
            get
            {
                if (RecordSize < 8) return 0;
                return base.ReadUInt16(0x6);
            }
        }

        /// <summary>
        /// File history flag
        /// </summary>
        /// <remarks>Not used before BIFF8</remarks>
        public uint HistoryFlag
        {
            get
            {
                if (RecordSize < 12) return 0;
                return base.ReadUInt32(0x8);
            }
        }

        /// <summary>
        /// Minimum Excel version to open this file
        /// </summary>
        /// <remarks>Not used before BIFF8</remarks>
        public uint MinVersionToOpen
        {
            get
            {
                if (RecordSize < 16) return 0;
                return base.ReadUInt32(0xC);
            }
        }

    }

    /// <summary>
    /// Represents BIFF EOF resord
    /// </summary>
    internal class XlsBiffEOF : XlsBiffRecord
    {
        internal XlsBiffEOF(byte[] bytes, uint offset) : base(bytes, offset) { }
        internal XlsBiffEOF(byte[] bytes) : this(bytes, 0) { }
    }

    /// <summary>
    /// Represents record with the only two-bytes value
    /// </summary>
    internal class XlsBiffSimpleValueRecord : XlsBiffRecord
    {
        internal XlsBiffSimpleValueRecord(byte[] bytes, uint offset) : base(bytes, offset) { }
        internal XlsBiffSimpleValueRecord(byte[] bytes) : this(bytes, 0) { }

        /// <summary>
        /// Returns value
        /// </summary>
        public ushort Value
        {
            get { return base.ReadUInt16(0x0); }
        }
    }

    /// <summary>
    /// Represents InterfaceHdr record in Wokrbook Globals
    /// </summary>
    internal class XlsBiffInterfaceHdr : XlsBiffRecord
    {
        internal XlsBiffInterfaceHdr(byte[] bytes, uint offset) : base(bytes, offset) { }
        internal XlsBiffInterfaceHdr(byte[] bytes) : this(bytes, 0) { }

        /// <summary>
        /// Returns CodePage for Interface Header
        /// </summary>
        public ushort CodePage
        {
            get { return base.ReadUInt16(0x0); }
        }
    }

    /// <summary>
    /// Represents Dimensions of worksheet
    /// </summary>
    internal class XlsBiffDimensions : XlsBiffRecord
    {
        internal XlsBiffDimensions(byte[] bytes, uint offset) : base(bytes, offset) { }
        internal XlsBiffDimensions(byte[] bytes) : this(bytes, 0) { }

        private bool isV8 = true;

        /// <summary>
        /// Gets or sets if BIFF8 addressing is used
        /// </summary>
        public bool IsV8
        {
            get { return isV8; }
            set { isV8 = value; }
        }

        /// <summary>
        /// Index of first row
        /// </summary>
        public uint FirstRow
        {
            get { return (isV8) ? base.ReadUInt32(0x0) : base.ReadUInt16(0x0); }
        }

        /// <summary>
        /// Index of last row + 1
        /// </summary>
        public uint LastRow
        {
            get { return (isV8) ? base.ReadUInt32(0x4) : base.ReadUInt16(0x2); }
        }

        /// <summary>
        /// Index of first column
        /// </summary>
        public ushort FirstColumn
        {
            get { return (isV8) ? base.ReadUInt16(0x8) : base.ReadUInt16(0x4); }
        }

        /// <summary>
        /// Index of last column + 1
        /// </summary>
        public ushort LastColumn
        {
            //get { return (isV8) ? base.ReadUInt16(0x10) : base.ReadUInt16(0x6); }
			// 05/01/2008 Paul.  Dimensions for Biff8 worksheets were calculated incorrectly.
			// http://www.codeproject.com/KB/office/Excel_DataReader.aspx?display=PrintAll&fid=320417&df=90&mpp=25&noise=3&sort=Position&view=Quick&fr=26&select=2513532#xx0xx
			// http://download.microsoft.com/download/0/B/E/0BE8BDD7-E5E8-422A-ABFD-4342ED7AD886/Excel97-2007BinaryFileFormat(xls)Specification.pdf
			get { return (isV8) ? base.ReadUInt16(0xA) : base.ReadUInt16(0x6); }
        }

    }

    /// <summary>
    /// Represents a worksheet index
    /// </summary>
    internal class XlsBiffIndex : XlsBiffRecord
    {
        internal XlsBiffIndex(byte[] bytes, uint offset) : base(bytes, offset) { }
        internal XlsBiffIndex(byte[] bytes) : this(bytes, 0) { }

        private bool isV8 = true;

        /// <summary>
        /// Gets or sets if BIFF8 addressing is used
        /// </summary>
        public bool IsV8
        {
            get { return isV8; }
            set { isV8 = value; }
        }

        /// <summary>
        /// Returns zero-based index of first existing row
        /// </summary>
        public uint FirstExistingRow
        {
            get { return (isV8) ? base.ReadUInt32(0x4) : base.ReadUInt16(0x4); }
        }

        /// <summary>
        /// Returns zero-based index of last existing row
        /// </summary>
        public uint LastExistingRow
        {
            get { return (isV8) ? base.ReadUInt32(0x8) : base.ReadUInt16(0x6); }
        }

        /// <summary>
        /// Returns addresses of DbCell records
        /// </summary>
        public uint[] DbCellAddresses
        {
            get
            {
                int size = RecordSize;
                int firstIdx = (isV8) ? 16 : 12;
                if (size <= firstIdx)
                    return new uint[0];
                List<uint> cells = new List<uint>((size - firstIdx) / 4);
                for (int i = firstIdx; i < size; i += 4)
                    cells.Add(base.ReadUInt32(i));
                return cells.ToArray();
            }
        }

    }

    /// <summary>
    /// Represents a Shared String Table in BIFF8 format
    /// </summary>
    internal class XlsBiffSST : XlsBiffRecord
    {
        private List<string> m_strings;
        private uint m_size = 0;
        private List<uint> continues = new List<uint>();

        internal XlsBiffSST(byte[] bytes, uint offset)
            : base(bytes, offset)
        {
            m_size = RecordSize;
            m_strings = new List<string>((int)Count);
        }
        internal XlsBiffSST(byte[] bytes) : this(bytes, 0) { }

        /// <summary>
        /// Returns count of strings in SST
        /// </summary>
        public uint Count
        {
            get { return base.ReadUInt32(0x0); }
        }

        /// <summary>
        /// Returns count of unique strings in SST
        /// </summary>
        public uint UniqueCount
        {
            get { return base.ReadUInt32(0x4); }
        }

        /// <summary>
        /// Reads strings from BIFF stream into SST array
        /// </summary>
        public void ReadStrings()
        {
            uint offset = (uint)m_readoffset + 8;
            uint last = (uint)m_readoffset + RecordSize;
            int lastcontinue = 0;
            uint count = UniqueCount;
            while (offset < last)
            {
                XlsFormattedUnicodeString str = new XlsFormattedUnicodeString(m_bytes, offset);
                uint prefix = str.HeadSize;
                uint postfix = str.TailSize;
                uint len = str.CharacterCount;
                uint size = prefix + postfix + len + ((str.IsMultiByte) ? len : 0);
                if (offset + size > last)
                {
                    if (lastcontinue >= continues.Count)
                        break;
                    uint contoffset = continues[lastcontinue];
                    byte encoding = Buffer.GetByte(m_bytes, (int)contoffset + 4);
                    byte[] buff = new byte[size * 2];
                    Buffer.BlockCopy(m_bytes, (int)offset, buff, 0, (int)(last - offset));
                    if (encoding == 0 && str.IsMultiByte == true)
                    {
                        len -= (last - prefix - offset) / 2;
                        string temp = Encoding.Default.GetString(m_bytes,
                                                                (int)contoffset + 5,
                                                                (int)len);
                        byte[] tempbytes = Encoding.Unicode.GetBytes(temp);
                        Buffer.BlockCopy(tempbytes, 0, buff, (int)(last - offset), tempbytes.Length);
                        Buffer.BlockCopy(m_bytes, (int)(contoffset + 5 + len), buff, (int)(last - offset + len + len), (int)postfix);
                        offset = contoffset + 5 + len + postfix;
                    }
                    else if (encoding == 1 && str.IsMultiByte == false)
                    {
                        len -= (last - offset - prefix);
                        string temp = Encoding.Unicode.GetString(m_bytes,
                                                                (int)contoffset + 5,
                                                                (int)(len + len));
                        byte[] tempbytes = Encoding.Default.GetBytes(temp);
                        Buffer.BlockCopy(tempbytes, 0, buff, (int)(last - offset), tempbytes.Length);
                        Buffer.BlockCopy(m_bytes, (int)(contoffset + 5 + len + len), buff, (int)(last - offset + len), (int)postfix);
                        offset = contoffset + 5 + len + len + postfix;
                    }
                    else
                    {
                        Buffer.BlockCopy(m_bytes, (int)contoffset + 5, buff, (int)(last - offset), (int)(size - last + offset));
                        offset = contoffset + 5 + size - last + offset;
                    }
                    last = contoffset + 4 + BitConverter.ToUInt16(m_bytes, (int)contoffset + 2);
                    lastcontinue++;

                    str = new XlsFormattedUnicodeString(buff, 0);
                }
                else
                {
                    offset += size;
                    if (offset == last)
                    {
                        if (lastcontinue < continues.Count)
                        {
                            uint contoffset = continues[lastcontinue];
                            offset = contoffset + 4;
                            last = offset + BitConverter.ToUInt16(m_bytes, (int)contoffset + 2);
                            lastcontinue++;
                        }
                        else
                            count = 1;
                    }
                }
                m_strings.Add(str.Value);
                count--;
                if (count == 0)
                    break;
            }
        }

        /// <summary>
        /// Returns string at specified index
        /// </summary>
        /// <param name="SSTIndex">Index of string to get</param>
        /// <returns>string value if it was found, empty string otherwise</returns>
        public string GetString(uint SSTIndex)
        {
            if (SSTIndex < m_strings.Count)
                return m_strings[(int)SSTIndex];
            else
                return "NOT FOUND #" + SSTIndex.ToString();// string.Empty;
        }

        /// <summary>
        /// Appends Continue record to SST
        /// </summary>
        /// <param name="fragment">Continue record</param>
        public void Append(XlsBiffContinue fragment)
        {
            continues.Add((uint)fragment.Offset);
            m_size += (uint)fragment.Size;
        }

    }

    /// <summary>
    /// Represents formatted unicode string in SST
    /// </summary>
    internal class XlsFormattedUnicodeString
    {
        protected byte[] m_bytes;
        protected uint m_offset;

        [Flags]
        public enum FormattedUnicodeStringFlags : byte
        {
            MultiByte = 0x01,
            HasExtendedString = 0x04,
            HasFormatting = 0x08,
        }

        public XlsFormattedUnicodeString(byte[] bytes, uint offset)
        {
            m_bytes = bytes;
            m_offset = offset;
        }

        /// <summary>
        /// Count of characters in string
        /// </summary>
        public ushort CharacterCount
        {
            get { return BitConverter.ToUInt16(m_bytes, (int)m_offset); }
        }

        /// <summary>
        /// String flags
        /// </summary>
        public FormattedUnicodeStringFlags Flags
        {
            get { return (FormattedUnicodeStringFlags)Buffer.GetByte(m_bytes, (int)m_offset + 2); }
        }

        /// <summary>
        /// Checks if string has Extended record
        /// </summary>
        public bool HasExtString
        {
            get { return false; } // ((Flags & FormattedUnicodeStringFlags.HasExtendedString) == FormattedUnicodeStringFlags.HasExtendedString); }
        }

        /// <summary>
        /// Checks if string has formatting
        /// </summary>
        public bool HasFormatting
        {
            get { return ((Flags & FormattedUnicodeStringFlags.HasFormatting) == FormattedUnicodeStringFlags.HasFormatting); }
        }

        /// <summary>
        /// Checks if string is unicode
        /// </summary>
        public bool IsMultiByte
        {
            get { return ((Flags & FormattedUnicodeStringFlags.MultiByte) == FormattedUnicodeStringFlags.MultiByte); }
        }

        /// <summary>
        /// Returns length of string in bytes
        /// </summary>
        private uint ByteCount
        {
            get { return (uint)(CharacterCount * ((IsMultiByte) ? 2 : 1)); }
        }

        /// <summary>
        /// Returns number of formats used for formatting (0 if string has no formatting)
        /// </summary>
        public ushort FormatCount
        {
            get
            {
                return (HasFormatting) ? BitConverter.ToUInt16(m_bytes, (int)m_offset + 3) : (ushort)0;
            }
        }

        /// <summary>
        /// Returns size of extended string in bytes, 0 if there is no one
        /// </summary>
        public uint ExtendedStringSize
        {
            get { return (HasExtString) ? (uint)BitConverter.ToUInt16(m_bytes, (int)m_offset + ((HasFormatting) ? 5 : 3)) : 0; }
        }

        /// <summary>
        /// Returns head (before string data) size in bytes
        /// </summary>
        public uint HeadSize
        {
            get { return (uint)((HasFormatting) ? 2 : 0) + (uint)((HasExtString) ? 4 : 0) + 3; }
        }

        /// <summary>
        /// Returns tail (after string data) size in bytes
        /// </summary>
        public uint TailSize
        {
            get { return (uint)((HasFormatting) ? 4 * FormatCount : 0) + (uint)((HasExtString) ? ExtendedStringSize : 0); }
        }

        /// <summary>
        /// Returns size of whole record in bytes
        /// </summary>
        public uint Size
        {
            get
            {
                uint extraSize = (uint)((HasFormatting) ? (2 + FormatCount * 4) : 0) + (uint)((HasExtString) ? (4 + ExtendedStringSize) : 0) + 3;
                if (!IsMultiByte)
                    return extraSize + CharacterCount;
                return extraSize + (uint)CharacterCount * 2;
            }
        }

        /// <summary>
        /// Returns string represented by this instance
        /// </summary>
        public string Value
        {
            get
            {
                if (IsMultiByte)
                    return Encoding.Unicode.GetString(m_bytes, (int)(m_offset + HeadSize), (int)ByteCount);
                else
                    return Encoding.Default.GetString(m_bytes, (int)(m_offset + HeadSize), (int)ByteCount);
            }
        }

    }

    /// <summary>
    /// Represents additional space for very large records
    /// </summary>
    internal class XlsBiffContinue : XlsBiffRecord
    {
        internal XlsBiffContinue(byte[] bytes, uint offset) : base(bytes, offset) { }
        internal XlsBiffContinue(byte[] bytes) : this(bytes, 0) { }
    }

    /// <summary>
    /// Represents row record in table
    /// </summary>
    internal class XlsBiffRow : XlsBiffRecord
    {
        internal XlsBiffRow(byte[] bytes, uint offset) : base(bytes, offset) { }
        internal XlsBiffRow(byte[] bytes) : this(bytes, 0) { }

        /// <summary>
        /// Zero-based index of row described
        /// </summary>
        public ushort RowIndex
        {
            get { return base.ReadUInt16(0x0); }
        }

        /// <summary>
        /// Index of first defined column
        /// </summary>
        public ushort FirstDefinedColumn
        {
            get { return base.ReadUInt16(0x2); }
        }

        /// <summary>
        /// Index of last defined column
        /// </summary>
        public ushort LastDefinedColumn
        {
            get { return base.ReadUInt16(0x4); }
        }

        /// <summary>
        /// Returns row height
        /// </summary>
        public uint RowHeight
        {
            get { return base.ReadUInt16(0x6); }
        }

        /// <summary>
        /// Returns row flags
        /// </summary>
        public ushort Flags
        {
            get { return base.ReadUInt16(0xC); }
        }

        /// <summary>
        /// Returns default format for this row
        /// </summary>
        public ushort XFormat
        {
            get { return base.ReadUInt16(0xE); }
        }

    }

    /// <summary>
    /// Represents cell-indexing record, finishes each row values block
    /// </summary>
    internal class XlsBiffDbCell : XlsBiffRecord
    {
        internal XlsBiffDbCell(byte[] bytes, uint offset) : base(bytes, offset) { }
        internal XlsBiffDbCell(byte[] bytes) : this(bytes, 0) { }

        /// <summary>
        /// Offset of first row linked with this record
        /// </summary>
        public int RowAddress
        {
            get { return (this.Offset - base.ReadInt32(0x0)); }
        }

        /// <summary>
        /// Addresses of cell values
        /// </summary>
        public uint[] CellAddresses
        {
            get
            {
                int a = RowAddress - 20;    // 20 assumed to be row structure size
                List<uint> tmp = new List<uint>();
                for (int i = 0x4; i < RecordSize; i += 4)
                    tmp.Add((uint)a + base.ReadUInt16(i));
                return tmp.ToArray();
            }
        }

    }

    /// <summary>
    /// Represents blank cell
    /// Base class for all cell types
    /// </summary>
    internal class XlsBiffBlankCell : XlsBiffRecord
    {
        internal XlsBiffBlankCell(byte[] bytes, uint offset) : base(bytes, offset) { }
        internal XlsBiffBlankCell(byte[] bytes) : this(bytes, 0) { }

        /// <summary>
        /// Zero-based index of row containing this cell
        /// </summary>
        public ushort RowIndex
        {
            get { return base.ReadUInt16(0x0); }
        }

        /// <summary>
        /// Zero-based index of column containing this cell
        /// </summary>
        public ushort ColumnIndex
        {
            get { return base.ReadUInt16(0x2); }
        }

        /// <summary>
        /// Format used for this cell
        /// </summary>
        public ushort XFormat
        {
            get { return base.ReadUInt16(0x4); }
        }

    }

    /// <summary>
    /// Represents a constant integer number in range 0..65535
    /// </summary>
    internal class XlsBiffIntegerCell : XlsBiffBlankCell
    {
        internal XlsBiffIntegerCell(byte[] bytes) : this(bytes, 0) { }
        internal XlsBiffIntegerCell(byte[] bytes, uint offset) : base(bytes, offset) { }

        /// <summary>
        /// Returns value of this cell
        /// </summary>
        public uint Value
        {
            get { return base.ReadUInt16(0x6); }
        }

    }

    /// <summary>
    /// Represents multiple Blank cell
    /// </summary>
    internal class XlsBiffMulBlankCell : XlsBiffBlankCell
    {
        internal XlsBiffMulBlankCell(byte[] bytes) : this(bytes, 0) { }
        internal XlsBiffMulBlankCell(byte[] bytes, uint offset) : base(bytes, offset) { }

        /// <summary>
        /// Returns format forspecified column, column must be between ColumnIndex and LastColumnIndex
        /// </summary>
        /// <param name="ColumnIdx">Index of column</param>
        /// <returns>Format</returns>
        public ushort GetXF(ushort ColumnIdx)
        {
            int ofs = 4 + 6 * (ColumnIdx - ColumnIndex);
            if (ofs > RecordSize - 2)
                return 0;
            return base.ReadUInt16(ofs);
        }

        /// <summary>
        /// Zero-based index of last described column
        /// </summary>
        public ushort LastColumnIndex
        {
            get { return base.ReadUInt16(RecordSize - 2); }
        }

    }

    /// <summary>
    /// Represents a floating-point number 
    /// </summary>
    internal class XlsBiffNumberCell : XlsBiffBlankCell
    {
        internal XlsBiffNumberCell(byte[] bytes) : this(bytes, 0) { }
        internal XlsBiffNumberCell(byte[] bytes, uint offset) : base(bytes, offset) { }

        /// <summary>
        /// Returns value of this cell
        /// </summary>
        public double Value
        {
            get { return base.ReadDouble(0x6); }
        }

    }

    /// <summary>
    /// Represents a string (max 255 bytes)
    /// </summary>
    internal class XlsBiffLabelCell : XlsBiffBlankCell
    {
        internal XlsBiffLabelCell(byte[] bytes) : this(bytes, 0) { }
        internal XlsBiffLabelCell(byte[] bytes, uint offset) : base(bytes, offset) { }

        private Encoding m_UseEncoding = Encoding.Default;

        /// <summary>
        /// Encoding used to deal with strings
        /// </summary>
        public Encoding UseEncoding
        {
            get { return m_UseEncoding; }
            set { m_UseEncoding = value; }
        }

        /// <summary>
        /// Length of string value
        /// </summary>
        public byte Length
        {
            get { return base.ReadByte(0x6); }
        }

        /// <summary>
        /// Returns value of this cell
        /// </summary>
        public string Value
        {
            get { return m_UseEncoding.GetString(base.ReadArray(0x8, Length * ((m_UseEncoding.IsSingleByte) ? 1 : 2))); }
        }

    }

    /// <summary>
    /// Represents an RK number cell
    /// </summary>
    internal class XlsBiffRKCell : XlsBiffBlankCell
    {
        internal XlsBiffRKCell(byte[] bytes) : this(bytes, 0) { }
        internal XlsBiffRKCell(byte[] bytes, uint offset) : base(bytes, offset) { }

        /// <summary>
        /// Returns value of this cell
        /// </summary>
        public double Value
        {
            get { return NumFromRK(base.ReadUInt32(0x6)); }
        }

        /// <summary>
        /// Decodes RK-encoded number
        /// </summary>
        /// <param name="rk">Encoded number</param>
        /// <returns></returns>
        public static double NumFromRK(uint rk)
        {
            double num;
            if ((rk & 0x2) == 0x2)
            {
                // int
                //num = (double)(int)(rk >> 2);
				// 05/01/2008 Paul.  Fix problem with negative numbers. 
				// http://www.codeproject.com/KB/office/Excel_DataReader.aspx?display=PrintAll&fid=320417&df=90&mpp=25&noise=3&sort=Position&view=Quick&fr=26&select=2513532#xx0xx
				num = (double)((int)rk >> 2);
            }
            else
            {
                // hi words of IEEE num
                num = BitConverter.Int64BitsToDouble(((long)(rk & 0xfffffffc) << 32));
            }
            if ((rk & 0x1) == 0x1)
                num /= 100; // divide by 100
            return num;
        }

    }

    /// <summary>
    /// Represents multiple RK number cells
    /// </summary>
    internal class XlsBiffMulRKCell : XlsBiffBlankCell
    {
        internal XlsBiffMulRKCell(byte[] bytes) : this(bytes, 0) { }
        internal XlsBiffMulRKCell(byte[] bytes, uint offset) : base(bytes, offset) { }

        /// <summary>
        /// Returns format for specified column
        /// </summary>
        /// <param name="ColumnIdx">Index of column, must be between ColumnIndex and LastColumnIndex</param>
        /// <returns></returns>
        public ushort GetXF(ushort ColumnIdx)
        {
            int ofs = 4 + 6 * (ColumnIdx - ColumnIndex);
            if (ofs > RecordSize - 2)
                return 0;
            return base.ReadUInt16(ofs);
        }

        /// <summary>
        /// Returns value for specified column
        /// </summary>
        /// <param name="ColumnIdx">Index of column, must be between ColumnIndex and LastColumnIndex</param>
        /// <returns></returns>
        public double GetValue(ushort ColumnIdx)
        {
            int ofs = 6 + 6 * (ColumnIdx - ColumnIndex);
            if (ofs > RecordSize)
                return 0;
            return XlsBiffRKCell.NumFromRK(base.ReadUInt32(ofs));
        }

        /// <summary>
        /// Returns zero-based index of last described column
        /// </summary>
        public ushort LastColumnIndex
        {
            get { return base.ReadUInt16(RecordSize - 2); }
        }

    }

    /// <summary>
    /// Represents a string stored in SST
    /// </summary>
    internal class XlsBiffLabelSSTCell : XlsBiffBlankCell
    {
        internal XlsBiffLabelSSTCell(byte[] bytes) : this(bytes, 0) { }
        internal XlsBiffLabelSSTCell(byte[] bytes, uint offset) : base(bytes, offset) { }

        /// <summary>
        /// Index of string in Shared String Table
        /// </summary>
        public uint SSTIndex
        {
            get { return base.ReadUInt32(0x6); }
        }

        /// <summary>
        /// Returns text using specified SST
        /// </summary>
        /// <param name="sst">Shared String Table record</param>
        /// <returns></returns>
        public string Text(XlsBiffSST sst)
        {
            return sst.GetString(SSTIndex);
        }

    }

    /// <summary>
    /// Represents a boolean or error value
    /// </summary>
    internal class XlsBiffBoolErrCell : XlsBiffBlankCell
    {
        internal XlsBiffBoolErrCell(byte[] bytes) : this(bytes, 0) { }
        internal XlsBiffBoolErrCell(byte[] bytes, uint offset) : base(bytes, offset) { }

        /// <summary>
        /// Gets code of error, if IsError is True
        /// </summary>
        public FORMULAERROR ErrorCode
        {
            get { return (FORMULAERROR)base.ReadByte(0x6); }
        }

        /// <summary>
        /// Gets boolean value, if IsError is False
        /// </summary>
        public bool Value
        {
            get { return (bool)(base.ReadByte(0x6) != 0); }
        }

        /// <summary>
        /// Checks if value is error
        /// </summary>
        public bool IsError
        {
            get { return (bool)(base.ReadByte(0x7) != 0); }
        }

    }

    /// <summary>
    /// Represents a string value of formula
    /// </summary>
    internal class XlsBiffFormulaString : XlsBiffRecord
    {
        internal XlsBiffFormulaString(byte[] bytes) : this(bytes, 0) { }
        internal XlsBiffFormulaString(byte[] bytes, uint offset) : base(bytes, offset) { }

        private Encoding m_UseEncoding = Encoding.Default;

        /// <summary>
        /// Encoding used to deal with strings
        /// </summary>
        public Encoding UseEncoding
        {
            get { return m_UseEncoding; }
            set { m_UseEncoding = value; }
        }

        /// <summary>
        /// Length of the string
        /// </summary>
        public ushort Length
        {
            get { return base.ReadUInt16(0x0); }
        }

        /// <summary>
        /// String text
        /// </summary>
        public string Value
        {
            //get { return m_UseEncoding.GetString(m_bytes, m_readoffset + ((m_UseEncoding.IsSingleByte) ? 2 : 3), Length * ((m_UseEncoding.IsSingleByte) ? 1 : 2)); }
			// 05/01/2008 Paul.  Use calculated values of a formula. 
			// http://www.codeproject.com/KB/office/Excel_DataReader.aspx?display=PrintAll&fid=320417&df=90&mpp=25&noise=3&sort=Position&view=Quick&fr=76&select=2513532#xx2513532xx
			get { return m_UseEncoding.GetString(m_bytes, m_readoffset + 2 + ((m_UseEncoding.IsSingleByte) ? 1 : 2), Length * ((m_UseEncoding.IsSingleByte) ? 1 : 2)); }
        }
    }

    /// <summary>
    /// Represents a cell containing formula
    /// </summary>
    internal class XlsBiffFormulaCell : XlsBiffNumberCell
    {
        internal XlsBiffFormulaCell(byte[] bytes) : this(bytes, 0) { }
        internal XlsBiffFormulaCell(byte[] bytes, uint offset) : base(bytes, offset) { }

        [Flags]
        public enum FormulaFlags : ushort
        {
            AlwaysCalc = 0x0001,
            CalcOnLoad = 0x0002,
            SharedFormulaGroup = 0x0008
        }

        private Encoding m_UseEncoding = Encoding.Default;

        /// <summary>
        /// Encoding used to deal with strings
        /// </summary>
        public Encoding UseEncoding
        {
            get { return m_UseEncoding; }
            set { m_UseEncoding = value; }
        }

        /// <summary>
        /// Formula flags
        /// </summary>
        public FormulaFlags Flags
        {
            get { return (FormulaFlags)(base.ReadUInt16(0xE)); }
        }

        /// <summary>
        /// Length of formula string
        /// </summary>
        public byte FormulaLength
        {
            get { return base.ReadByte(0xF); }
        }

        /// <summary>
        /// Returns type-dependent value of formula
        /// </summary>
        public new object Value
        {
            get
            {
                long val = base.ReadInt64(0x6);
                if (((ulong)val & 0xFFFF000000000000) == 0xFFFF000000000000)
                {
                    byte type = (byte)(val & 0xFF);
                    byte code = (byte)((val >> 16) & 0xFF);
                    switch (type)
                    {
                        case 0:     // String
                            XlsBiffFormulaString str = XlsBiffRecord.GetRecord(m_bytes, (uint)(Offset + Size)) as XlsBiffFormulaString;
                            if (str == null)
                                return string.Empty;
                            else
                            {
                                str.UseEncoding = m_UseEncoding;
                                return str.Value;
                            }
                        case 1:     // Boolean
                            return (bool)(code != 0);
                        case 2:     // Error
                            return (FORMULAERROR)code;
                        default:
                            return null;
                    }
                }
                else
                    return BitConverter.Int64BitsToDouble(val);
            }
        }

        public string Formula
        {
            get { return Encoding.Default.GetString(base.ReadArray(0x10, FormulaLength)); }
        }

    }

    /// <summary>
    /// Represents Workbook's global window description
    /// </summary>
    internal class XlsBiffWindow1 : XlsBiffRecord
    {
        [Flags()]
        public enum Window1Flags : ushort
        {
            Hidden = 0x1,
            Minimized = 0x2,
            //(Reserved) = 0x4,
            HScrollVisible = 0x8,
            VScrollVisible = 0x10,
            WorkbookTabs = 0x20
            //(Other bits are reserved)
        }

        internal XlsBiffWindow1(byte[] bytes, uint offset) : base(bytes, offset) { }
        internal XlsBiffWindow1(byte[] bytes) : this(bytes, 0) { }

        /// <summary>
        /// Returns X position of a window
        /// </summary>
        public ushort Left
        {
            get { return base.ReadUInt16(0x0); }
        }

        /// <summary>
        /// Returns Y position of a window
        /// </summary>
        public ushort Top
        {
            get { return base.ReadUInt16(0x2); }
        }

        /// <summary>
        /// Returns width of a window
        /// </summary>
        public ushort Width
        {
            get { return base.ReadUInt16(0x4); }
        }

        /// <summary>
        /// Returns height of a window
        /// </summary>
        public ushort Height
        {
            get { return base.ReadUInt16(0x6); }
        }

        /// <summary>
        /// Returns window flags
        /// </summary>
        public Window1Flags Flags
        {
            get { return (Window1Flags)base.ReadUInt16(0x8); }
        }

        /// <summary>
        /// Returns active workbook tab (zero-based)
        /// </summary>
        public ushort ActiveTab
        {
            get { return base.ReadUInt16(0xA); }
        }

        /// <summary>
        /// Returns first visible workbook tab (zero-based)
        /// </summary>
        public ushort FirstVisibleTab
        {
            get { return base.ReadUInt16(0xC); }
        }

        /// <summary>
        /// Returns number of selected workbook tabs
        /// </summary>
        public ushort SelectedTabCount
        {
            get { return base.ReadUInt16(0xE); }
        }

        /// <summary>
        /// Returns workbook tab width to horizontal scrollbar width
        /// </summary>
        public ushort TabRatio
        {
            get { return base.ReadUInt16(0x10); }
        }

    }

    /// <summary>
    /// Represents Sheet record in Workbook Globals
    /// </summary>
    internal class XlsBiffBoundSheet : XlsBiffRecord
    {
        public enum SheetType : byte
        {
            Worksheet = 0x0,
            MacroSheet = 0x1,
            Chart = 0x2,
            VBModule = 0x6
        }

        public enum SheetVisibility : byte
        {
            Visible = 0x0,
            Hidden = 0x1,
            VeryHidden = 0x2
        }

        internal XlsBiffBoundSheet(byte[] bytes, uint offset) : base(bytes, offset) { }
        internal XlsBiffBoundSheet(byte[] bytes) : this(bytes, 0) { }

        /// <summary>
        /// Worksheet data start offset
        /// </summary>
        public uint StartOffset
        {
            get { return base.ReadUInt32(0x0); }
        }

        /// <summary>
        /// Type of worksheet
        /// </summary>
        public SheetType Type
        {
            get { return (SheetType)base.ReadByte(0x4); }
        }

        /// <summary>
        /// Visibility of worksheet
        /// </summary>
        public SheetVisibility VisibleState
        {
            get { return (SheetVisibility)(base.ReadByte(0x5) & 0x3); }
        }

        /// <summary>
        /// Name of worksheet
        /// </summary>
        public string SheetName
        {
            get
            {
                ushort len = base.ReadByte(0x6);
                ushort size = RecordSize;
                int start = 0x8;
                if (isV8)
                    if (base.ReadByte(0x7) == 0)
                        return Encoding.Default.GetString(m_bytes, m_readoffset + start, len);
                    else
                        return m_UseEncoding.GetString(m_bytes, m_readoffset + start, (m_UseEncoding.IsSingleByte) ? len : len * 2);
                else
                    return Encoding.Default.GetString(m_bytes, m_readoffset + start - 1, len);
            }
        }

        private Encoding m_UseEncoding = Encoding.Default;

        /// <summary>
        /// Encoding used to deal with strings
        /// </summary>
        public Encoding UseEncoding
        {
            get { return m_UseEncoding; }
            set { m_UseEncoding = value; }
        }

        private bool isV8 = true;

        /// <summary>
        /// Specifies if BIFF8 format should be used
        /// </summary>
        public bool IsV8
        {
            get { return isV8; }
            set { isV8 = value; }
        }

    }

    /// <summary>
    /// Represents Globals section of workbook
    /// </summary>
    internal class XlsWorkbookGlobals
    {

        private XlsBiffInterfaceHdr m_InterfaceHdr = null;

        public XlsBiffInterfaceHdr InterfaceHdr
        {
            get { return m_InterfaceHdr; }
            set { m_InterfaceHdr = value; }
        }

        private XlsBiffRecord m_MMS = null;

        public XlsBiffRecord MMS
        {
            get { return m_MMS; }
            set { m_MMS = value; }
        }

        private XlsBiffRecord m_WriteAccess = null;

        public XlsBiffRecord WriteAccess
        {
            get { return m_WriteAccess; }
            set { m_WriteAccess = value; }
        }

        private XlsBiffSimpleValueRecord m_CodePage = null;

        public XlsBiffSimpleValueRecord CodePage
        {
            get { return m_CodePage; }
            set { m_CodePage = value; }
        }

        private XlsBiffRecord m_DSF = null;

        public XlsBiffRecord DSF
        {
            get { return m_DSF; }
            set { m_DSF = value; }
        }

        private XlsBiffRecord m_Country = null;

        public XlsBiffRecord Country
        {
            get { return m_Country; }
            set { m_Country = value; }
        }

        private XlsBiffSimpleValueRecord m_Backup = null;

        public XlsBiffSimpleValueRecord Backup
        {
            get { return m_Backup; }
            set { m_Backup = value; }
        }

        private List<XlsBiffRecord> m_Fonts = new List<XlsBiffRecord>();

        public List<XlsBiffRecord> Fonts
        {
            get { return m_Fonts; }
        }

        private List<XlsBiffRecord> m_Formats = new List<XlsBiffRecord>();

        public List<XlsBiffRecord> Formats
        {
            get { return m_Formats; }
        }

        private List<XlsBiffRecord> m_ExtendedFormats = new List<XlsBiffRecord>();

        public List<XlsBiffRecord> ExtendedFormats
        {
            get { return m_ExtendedFormats; }
        }

        private List<XlsBiffRecord> m_Styles = new List<XlsBiffRecord>();

        public List<XlsBiffRecord> Styles
        {
            get { return m_Styles; }
        }

        private List<XlsBiffBoundSheet> m_Sheets = new List<XlsBiffBoundSheet>();

        public List<XlsBiffBoundSheet> Sheets
        {
            get { return m_Sheets; }
        }

        private XlsBiffSST m_SST = null;

        /// <summary>
        /// Shared String Table of workbook
        /// </summary>
        public XlsBiffSST SST
        {
            get { return m_SST; }
            set { m_SST = value; }
        }

        private XlsBiffRecord m_ExtSST = null;

        public XlsBiffRecord ExtSST
        {
            get { return m_ExtSST; }
            set { m_ExtSST = value; }
        }
    }

    /// <summary>
    /// Represents Worksheet section in workbook
    /// </summary>
    internal class XlsWorksheet
    {
        private int m_Index = 0;
        private string m_Name = string.Empty;
        private uint m_dataOffset = 0;

        public XlsWorksheet(int index, XlsBiffBoundSheet refSheet)
        {
            m_Index = index;
            m_Name = refSheet.SheetName;
            m_dataOffset = refSheet.StartOffset;
        }

        /// <summary>
        /// Name of worksheet
        /// </summary>
        public string Name
        {
            get { return m_Name; }
        }

        /// <summary>
        /// Zero-based index of worksheet
        /// </summary>
        public int Index
        {
            get { return m_Index; }
        }

        /// <summary>
        /// Offset of worksheet data
        /// </summary>
        public uint DataOffset
        {
            get { return m_dataOffset; }
        }

        private DataTable m_Data = null;

        /// <summary>
        /// DataTable with worksheet data
        /// </summary>
        public DataTable Data
        {
            get { return m_Data; }
            set { m_Data = value; }
        }

        private XlsBiffSimpleValueRecord m_CalcMode = null;

        public XlsBiffSimpleValueRecord CalcMode
        {
            get { return m_CalcMode; }
            set { m_CalcMode = value; }
        }

        private XlsBiffSimpleValueRecord m_CalcCount = null;

        public XlsBiffSimpleValueRecord CalcCount
        {
            get { return m_CalcCount; }
            set { m_CalcCount = value; }
        }

        private XlsBiffSimpleValueRecord m_RefMode = null;

        public XlsBiffSimpleValueRecord RefMode
        {
            get { return m_RefMode; }
            set { m_RefMode = value; }
        }

        private XlsBiffSimpleValueRecord m_Iteration = null;

        public XlsBiffSimpleValueRecord Iteration
        {
            get { return m_Iteration; }
            set { m_Iteration = value; }
        }

        private XlsBiffRecord m_Delta = null;

        public XlsBiffRecord Delta
        {
            get { return m_Delta; }
            set { m_Delta = value; }
        }

        private XlsBiffDimensions m_Dimensions = null;

        /// <summary>
        /// Dimensions of worksheet
        /// </summary>
        public XlsBiffDimensions Dimensions
        {
            get { return m_Dimensions; }
            set { m_Dimensions = value; }
        }

        private XlsBiffRecord m_Window2 = null;

        public XlsBiffRecord Window2
        {
            get { return m_Window2; }
            set { m_Window2 = value; }
        }

    }

}
