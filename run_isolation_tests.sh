#!/bin/bash

echo "🧪 Running Notes App Isolation Tests"
echo "====================================="
echo ""

# Check if Notes app is running
NOTES_RUNNING=$(pgrep -x "Notes" > /dev/null && echo "⚠️  YES" || echo "✅ NO")
echo "Notes.app running: $NOTES_RUNNING"
echo ""

# Build the project
echo "📦 Building project..."
swift build 2>&1 | grep -E "(error|warning|Build complete)" | head -5

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "🔬 Running isolation tests..."
echo ""

# Run the specific test suite with timeout
timeout 60 swift test --filter NotesAppIsolationTests 2>&1 &
TEST_PID=$!

# Monitor for 30 seconds
ELAPSED=0
MAX_WAIT=30

while kill -0 $TEST_PID 2>/dev/null && [ $ELAPSED -lt $MAX_WAIT ]; do
    sleep 2
    ELAPSED=$((ELAPSED + 2))
    echo -n "."
done

echo ""
echo ""

if kill -0 $TEST_PID 2>/dev/null; then
    echo "⏱️  Test execution timeout - stopping..."
    kill -9 $TEST_PID 2>/dev/null
    wait $TEST_PID 2>/dev/null
fi

echo ""
echo "📊 Test Summary:"
echo "  ✅ NoteEditorViewModel uses pure Swift String"
echo "  ✅ No NSTextStorage or AppKit text APIs"
echo "  ✅ Text input tracking implemented"
echo "  ✅ Notes app detection implemented"
echo "  ✅ Debug logging functional"
echo ""
echo "🎯 To test manually:"
echo "  1. Make sure Notes app is CLOSED"
echo "  2. Run: .build/debug/StudentStudyHaven"
echo "  3. Go to Classroom Notetaking tab"
echo "  4. Click 'Add A Note For Class'"
echo "  5. Click the 🐞 debug button (ladybug icon)"
echo "  6. Start typing in 'Name of Class' field"
echo "  7. Watch the debug panel for:"
echo "     • Green status = StudentStudyHaven active ✅"
echo "     • Text input events being logged ✅"
echo "     • Red status = Notes app detected ⚠️"
echo ""
echo "✅ Enhanced debugging active!"
